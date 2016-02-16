#!/usr/bin/env ruby

###############################################################################
# Tidy Regression Test Suite
#  Run this script with `help` for more information (or examine this file.)
###############################################################################

require 'bundler/setup'  # Provides environment for this script.
require 'logger'         # Log output simplified.
require 'open3'          # Run executables and capture output.
require 'fileutils'      # File utilities.
require 'date'           # Make sure DateTime works.
require 'fileutils'      # compare_file, etc.
require 'thor'           # thor provides robust command line parameter parsing.


###############################################################################
# module Which
#  Cross-platform "which" utility for Ruby.
#  https://gist.github.com/steakknife/88b6c3837a5e90a08296
###############################################################################
module Which
  # similar to `which {{cmd}}`, except relative paths *are* always expanded
  # returns: first match absolute path (String) to cmd (no symlinks followed),
  #          or nil if no executable found
  def which(cmd)
    which0(cmd) do |abs_exe|
      return abs_exe
    end
    nil
  end

  # similar to `which -a {{cmd}}`, except relative paths *are* always expanded
  # returns: always an array, or [] if none found
  def which_all(cmd)
    results = []
    which0(cmd) do |abs_exe|
      results << abs_exe
    end
    results
  end

  def real_executable?(f)
    File.executable?(f) && !File.directory?(f)
  end

  def executable_file_extensions
    ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  end

  def search_paths
    ENV['PATH'].split(File::PATH_SEPARATOR)
  end

  def find_executable(path, cmd, &_block)
    executable_file_extensions.each do |ext|
      # rubocop:disable Lint/AssignmentInCondition
      if real_executable?( (abs_exe = File.expand_path(cmd + ext, path) ))
        yield(abs_exe)
      end
      # rubocop:enable Lint/AssignmentInCondition
    end
  end

  # internal use only
  # +_found_exe+ is yielded to on *all* successful match(es),
  #              with path to absolute file (String)
  def which0(cmd, &found_exe)
    # call expand_path(f, nil) == expand_path(f) for relative/abs path cmd
    find_executable(nil, cmd, &found_exe) if File.basename(cmd) != cmd

    search_paths.each do |path|
      find_executable(path, cmd, &found_exe)
    end
  end

  module_function(*public_instance_methods) # `extend self`, sorta
end # module Which


################################################################################
# module TidyRegressionTesting
#  This module encapsulates module-level variables, utilities, logging,
#  the CLI handling class, and the regression testing class.
###############################################################################
module TidyRegressionTesting

  ###########################################################
  # Setup
  #  Change these variables to specify different defaults,
  #  although there's probably no good reason to change
  #  them.
  ###########################################################
  @@default_cases = 'cases'
  @@default_results = 'results'           # prefix only!
  @@default_conf = 'config_default.conf'


  ###########################################################
  # Logging
  ###########################################################
  @@log = Logger.new(STDOUT)
  @@log.level = Logger::ERROR
  @@log.datetime_format = '%Y-%m-%d %H:%M:%S'


  ###########################################################
  # property log_level
  ###########################################################
  def self.log_level
    @@log.level
  end

  def self.log_level=(level)
    @@log.level = level
  end
  
  
  #############################################################################
  # class TidyExe
  #  This class abstracts the tidy command line executable and provides its
  #  services within Ruby.
  #############################################################################
  class TidyExe

    include TidyRegressionTesting
    
    attr_accessor :source_file
    attr_accessor :config
    attr_accessor :arguments_extra

    #########################################################
    # initialize
    #########################################################
    def initialize
      @path = nil                # Executable path.
      @version = nil             # Complete version string.
      @version_major = nil       # Major version.
      @version_minor = nil       # Minor version.
      @version_patch = nil       # Patch version.
      @version_extra = nil       # Things beyond the patch, if any.
      @version_plain = nil       # major.minor.patch _only_
      @source_file = nil         # Source file to Tidy.
      @config = nil              # TidyConfig instance to use.
      @arguments_extra = nil     # Additional command-line arguments to pass.
    end


    #########################################################
    # property path
    #  Indicates the complete path to the tidy executable.
    #  If not set then the default is the OS default, if
    #  found. Value is nil when the path is not valid.
    #########################################################
    def path
      if @path.nil?
        self.path = Which::which('tidy')
      end
      @path
    end

    def path=(value)
      if !value.nil? && File.basename(value, '.*').start_with?('tidy') && File.executable?(value)
        @path = File.expand_path(value)
        @@log.info "#{__method__}: Will use Tidy at #{value}"
      else
        @path = nil
        @@log.error "#{__method__}: No valid Tidy at #{value}"
      end
      @version = nil
    end

    def path?
      !self.path.nil?
    end


    #########################################################
    # property version and company.
    #  Returns the tidy version string of the executable.
    #  nil value indicates that tidy is not found.
    #########################################################
    def version
      if path.nil?
        @@log.info "#{__method__}: Tried to get Tidy version with no valid Tidy specified."
        nil
      else
        if @version.nil?
          pwd = Dir.pwd
          Dir.chdir(File.dirname(path))
          result = Open3.capture3("#{File.join('.',File.basename(path))} -v")
          Dir.chdir(pwd)
          result[0].split.last if result
        else
          @version
        end
      end
    end

    def version?
      !self.version.nil?
    end

    def version_major
      parse_version( version ) if @version_major.nil?
      @version_major
    end

    def version_minor
      parse_version( version ) if @version_minor.nil?
      @version_minor
    end

    def version_patch
      parse_version( version ) if @version_patch.nil?
      @version_patch
    end

    def version_extra
      parse_version( version ) if @version_extra.nil?
      @version_extra
    end

    def version_plain
      parse_version( version ) if @version_plain.nil?
      @version_plain
    end
    
    
    #########################################################
    # execute( file, config ) | output_file, error_file, status |
    # execute | output_file, error_file, status |
    #  Sets source_file to file and config_file to config,
    #  and then executes Tidy using a block for the results.
    #########################################################
    def execute( file = nil, config = nil )
      self.source_file = file unless file.nil?
      if self.source_file.nil?
        @@log.error "#{__method__}: Source file is nil or invalid."
        return false
      end

      self.config = config unless config.nil?
      if self.config.nil?
        @@log.error "#{__method__}: Config is nil or invalid."
        return false
      end

      if self.path.nil?
        @@log.error "#{__method__}: No valid Tidy has been set or could be found."
        return false
      end

      # Check the config_file for cases of write-back: yes, in which case we
      # will create a backup for restoration after the Tidy process.
      writes_back = self.config.config_matches?('write-back', 'yes')

      Dir.mktmpdir do | tmp | # temp stuff cleaned up automatically.
        if writes_back
          @@log.info "#{__method__}: Dealing with write-back: yes by creating backup of original file."
          FileUtils.cp(self.source_file, "#{self.source_file}.bak")
        end
        err_path = "#{File.join(tmp, 'tidy_err.tmp')}"
        tdy_path = "#{File.join(tmp, 'tidy_out.tmp')}"
        command = "#{File.join('.', File.basename(self.path))} -o #{tdy_path} -f #{err_path} -config #{self.config.actual_path} --tidy-mark no #{self.arguments_extra} #{self.source_file}"
        pwd = Dir.pwd
        Dir.chdir(File.dirname(self.path))
        @@log.info "#{__method__}: performing #{command}"
        tidy_result = Open3.capture3(command)
        Dir.chdir(pwd)
        if writes_back
          # The original source_file is now tidy'd, so put it where the rest of the
          # test suite expects to find tidy results files, and restore the original.
          @@log.info "#{__method__}: Restoring original source file after write-back: yes."
          FileUtils.mv(self.source_file, tdy_path)
          FileUtils.mv("#{self.source_file}.bak", self.source_file)
        end
        yield tdy_path, err_path, tidy_result[2].exitstatus if block_given?
      end
      true
    end # execute


    private

    #########################################################
    # parse_version
    #  Build our version components from the version.
    #########################################################
    def parse_version( vers )
      @version_major = nil
      @version_minor = nil
      @version_patch = nil
      @version_extra = nil
      if vers
        vers.match(/(.*)\.(.*)\.(\d*)(.*)/) do |matches|
          @version_major = matches[1]
          @version_minor = matches[2]
          @version_patch = matches[3]
          @version_extra = matches[4]
        end
        @version_plain = "#{@version_major}.#{@version_minor}.#{@version_patch}"
      end
    end # parse_version

  end # class TidyExe



  #############################################################################
  # class CasesDirectory
  #  This class manages a cases directory and provides various utilities
  #  for working with them.
  #############################################################################
  class CasesDirectory

    include TidyRegressionTesting

    #########################################################
    # initialize
    #########################################################
    def initialize
      @path = nil      # Path to the cases directory.
      @tidy_exe = nil  # An instance of TidyEXE.
    end


    #########################################################
    # property path
    #  Indicates the directory from which to read the test
    #  cases.
    #  By default path will consist of the @@default_cases.
    #  If you set the property tidy_exe, then path will
    #  be automatically selected using @@default_cases and
    #  a version number. You can also set path directly.
    #  The path will be nil if none of the above yield a
    #  working directory.
    #  @todo: this needs to select the closest match, not just exact match!
    #########################################################
    def path
      if @path.nil?
        self.path = @@default_cases
      end
      @path
    end

    def path=( value )
      if !value.nil? && File.exist?(value)
        @@log.info "#{__method__}: Cases directory is #{value}"
        @path = File.expand_path(value)
      else
        @@log.error "#{__method__}: Cases directory #{value} doesn't exist"
        @path = nil
      end
    end

    def path?
      !self.path.nil?
    end


    #########################################################
    # property tidy_exe
    #  This is a convenience for setting the path property
    #  using the version of Tidy that is being used. It will
    #  try to set the path to, e.g., cases-5.1.38 if the
    #  TideEXE instance is 5.1.38.
    #########################################################
    def tidy_exe
      @tidy_exe
    end

    def tidy_exe=( value )
      if !value.nil? && value.version
        self.path = "#{@@default_cases}-#{value.version}"
      end
      @tidy_exe = value
    end


    #########################################################
    # property cases
    #  If path is valid, then cases will consist of an array
    #  of case files within the cases directory.
    #########################################################
    def cases
      if self.path?
        pattern = File.join(self.dir_cases, '**', '*.{html,xml,xhtml}')
        result = Dir[pattern].reject { |f| f[%r{-expect}] }.sort
      else
        result = []
      end
      result
    end


  end # class CasesDirectory
  
  
  
  #############################################################################
  # class TidyConfig
  #  This class manages a tidy configuration file for a particular test case.
  #  Configuration files may contain additional metadata used by the testing
  #  suite, including references to _real_ configuration files that should be
  #  used when executing Tidy for a test case.
  #############################################################################
  class TidyConfig

    include TidyRegressionTesting

    attr_reader :path_content
    attr_reader :actual_path
    attr_reader :expected_exit
    attr_reader :expected_errout
    attr_reader :report_info

    #########################################################
    # initialize
    #########################################################
    def initialize
      @path = nil             # Path to the specified config file.
      @path_content = nil     # Content of config file being used.
      @actual_path = nil      # The file to be passed to Tidy.
      @expected_exit = 0      # The expected Tidy exit code for this configuration.
      @expected_errout = nil  # Abbreviated errout output against which to test.
      @report_info = nil      # Report info to be included in the final report.
    end


    #########################################################
    # property path
    #  The path to the specified configuration file, which
    #  contains test metadata including optional Tidy config
    #  options.
    #########################################################
    def path
      @path
    end

    def path=( value )
      if !value.nil? && File.exists?(value)
        @path = value

        # Get the desired metadata from the configuration file.
        @path_content = File.open(self.path) { |f| f.read } # temp!

        if self.path_content =~ /^(\/\/|#).*USE_DEFAULT_CONFIG/i
          @actual_path = @@default_conf
        else
          @actual_path = self.path
        end

        pattern = /^(\/\/|#)\s?EXPECTED_EXIT\s?=\s?(\d+)/i
        if self.path_content =~ pattern
          @expected_exit = self.path_content.match(pattern)[2]
        else
          @expected_exit = 0
        end

        pattern = /^(\/\/|#)\s?EXPECTED_ERROUT\s?=\s?([^\s]*)/i
        if self.path_content =~ pattern
          @expected_errout = self.path_content.match(pattern)[2]
        else
          @expected_errout = nil
        end

        @report_info = ''
        self.path_content.each_line do |line|
          pattern = /^\/\/\/\s?(.*)$/
          @report_info << line.match(pattern)[1] if line =~ pattern
        end

        # Finally load the real configuration file.
        @path_content = File.open(self.actual_path) { |f| f.read } # real!

      else
        @@log.error "#{__method__}: Configuration file #{value} doesn't exist"
        @path = nil
      end
    end

    def path?
      !self.path.nil?
    end


    #########################################################
    # config_matches?
    #  Returns true if the current config file contains the
    #  specified option with the value (as string).
    #  @todo: match synonyms, e.g., yes, true, etc.
    #########################################################
    def config_matches?(option, value)
      pattern = /^#{option}: *?#{value}.*?/i
      !(@path_content =~ pattern).nil?
    end

  end # class TidyConfig



  #############################################################################
  # class TestReport
  #  This class handles output reporting for test cases.
  #############################################################################
  class TestReport

    include TidyRegressionTesting

    attr_accessor :include_info

    #########################################################
    # initialize
    #########################################################
    def initialize
      @output_dir = nil     # directory to write test reports.
      @include_info = true  # include report_info in test report?
    end


    #########################################################
    # property output_dir
    #  Indicates where to write test reports and failed
    #  files.
    #########################################################
    def output_dir
      @output_dir
    end

    def output_dir=( value )
      if !value.nil? && File.exist?(value)
        @@log.info "#{__method__}: Will put report output into #{value}"
        @output_dir = value
      else
        @@log.error "#{__method__}: Output directory #{value} can't be used"
        @output_dir = nil

      end

    def output_dir?

    end


    #########################################################
    # generate_alltest
    #  Generates a test report for exit status only.
    #########################################################
    def generate_alltest

    end


    #########################################################
    # generate_alltestc
    #  Generates a test report for exit status and HTML
    #  comparison.
    #########################################################
    def generate_alltestc

    end


    #########################################################
    # generate_comprehensive
    #  Generates a comprehensive test report including
    #  comparing the actual errout.
    #########################################################
    def generate_comprehensive

    end


  end # class TestReport
  


  #############################################################################
  # class TestCase
  #  This class performs a single test case and maintains data about that
  #  case which can be later used in reporting.
  #############################################################################
  class TestCase

    include TidyRegressionTesting

    attr_accessor :tidy_exe
    attr_accessor :tidy_config

    attr_reader :expect_html_file
    attr_reader :expect_txt_file
    attr_reader :valid
    attr_reader :tested
    attr_reader :passed_output
    attr_reader :passed_errout
    attr_reader :passed_status

    @@all_cases = []  # Singleton array of all TestCase instances.


    #########################################################
    # initialize
    #########################################################
    def initialize
      @tidy_exe = nil          # TidyEXE instance for this case.
      @tidy_config = nil       # TidyConfig instance for this case.
      @case_file = nil         # The file to be tested.
      @expect_html_file = nil  # The HTML expect file for this case.
      @expect_txt_file = nil   # The HTML errout file for this case.
      @valid = false           # Indicates this is a valid case.
      @tested = false          # Indicates this case has been tested.
      @passed_output = false   # Indicates output testing passed.
      @passed_errout = false   # Indicates errout testing passed.
      @passed_status = false   # Indicates exit status passed.
      @@all_cases << self
    end


    #########################################################
    # property case_file
    #########################################################
    def case_file
      @case_file
    end

    def case_file=( value )
      if !value.nil? && File.exist?(value)
        @@log.info "#{__method__}: Will use case file #{value}"
        @case_file = value
      else
        @@log.error "#{__method__}: Case file #{value} doesn't exist"
        @case_file = nil
      end

    end

    def case_file?
      !@case_file.nil?
    end


    #########################################################
    # execute
    #  Executes the test, yielding a block so the caller
    #  can handle writing files, etc.
    #########################################################
    def execute

    end


    #########################################################
    # compare_html
    #  Tries to compare HTML files without respect to line
    #  endings.
    #########################################################
    def compare_html(file1, file2)
      content1 = File.exists?(file1) ? File.open(file1) { |f| f.read } : nil
      content2 = File.exists?(file2) ? File.open(file2) { |f| f.read } : nil
      content1 = content1.empty? ? nil : content1.encode(content1.encoding, :universal_newline => true) unless content1.nil?
      content2 = content2.empty? ? nil : content2.encode(content2.encoding, :universal_newline => true) unless content2.nil?
      content1 == content2
    end # compare_html


    #########################################################
    # compare_errs( file1, file2 )
    #  Tries to compare error output without respect to
    #  line endings, and ignoring everything after the
    #  error summary output line.
    #########################################################
    def compare_errs(file1, file2)
      pattern = /^(No warnings or errors were found\.)|(\d warnings?, \d errors? were found!)/
      content1 = nil
      content2 = nil

      gnu_emacs = config_matches?('gnu-emacs', 'yes')
      emacs_pattern = /^.*(#{File.basename(self.source_file)}:.*)/i

      if File.exists?(file1)
        tmp = File.open(file1) { |f| f.readlines }
        content1 = tmp.take_while { |line| line !~ pattern }
        content1 << tmp[content1.count] unless tmp[content1.count].nil?
        if gnu_emacs
          content1.map! do |line|
            line.match(emacs_pattern) { |m| m[1] }
          end
        end
      end

      if File.exists?(file2)
        tmp = File.open(file2) { |f| f.readlines }
        content2 = tmp.take_while { |line| line !~ pattern }
        content2 << tmp[content2.count] unless tmp[content2.count].nil?
        if gnu_emacs
          content2.map! do |line|
            line.match(emacs_pattern) { |m| m[1] }
          end
        end
      end

      content1 == content2
    end # compare_errs


    #########################################################
    # + property all_cases
    #########################################################
    def self.all_cases
      @@all_cases
    end


    #########################################################
    # + run_a_test
    #########################################################
    def self.run_a_test

    end


  end # class TestCase



  #############################################################################
  # class TestRunner
  #  This class orchestrates input and output locations, runs one or multiple
  #  tests, and generates report output.
  #############################################################################
  class TestRunner
  
    include TidyRegressionTesting

    attr_accessor :tidy            # Our owned instance of TidyExe.
  
    #########################################################
    # initialize
    #########################################################
    def initialize
      @dir_cases = nil
      @dir_results = nil
      @tidy = TidyExe.new
    end

    #########################################################
    # property dir_cases
    #  Indicates the directory from which to read the test
    #  cases.
    #########################################################
    def dir_cases
      if @dir_cases.nil?
        self.dir_cases = @@default_cases
      end
      @dir_cases
    end

    def dir_cases=( value )
      @dir_cases = File.expand_path(value)
    end

    def dir_cases?
      if File.exists?(dir_cases) && File.readable?(dir_cases)
        @@log.info "#{__method__}: Will uses cases directory #{dir_cases}"
        true
      else
        @@log.error "#{__method__}: Cases directory #{dir_cases} does not exist or could not be read."
        false
      end
    end

    #########################################################
    # property dir_results
    #  Indicates the directory in which to write test pass
    #  and failure information. The value will be modified
    #  with the current tidy_version upon setting.
    #########################################################
    def dir_results
      if @dir_results.nil?
        self.dir_results = @@default_results
      end
      @dir_results
    end

    def dir_results=( value )
      if self.tidy.version?
        result = "#{value}-#{self.tidy.version}"
      else
        result = "#{value}-0.0.0"
      end
      @dir_results = File.expand_path(result)
    end

    def dir_results?
      unless File.exists?(dir_results)
        begin
          Dir.mkdir(dir_results)
        rescue SystemCallError
          @@log.error "#{__method__}: Directory #{dir_results} could not be created."
          return false
        end
        @@log.info "#{__method__}: Created results directory #{dir_results}"
      end
      if File.readable?(dir_results)
        @@log.info "#{__method__}: Will place results into #{dir_results}"
        true
      else
        @@log.error "#{__method__}: Directory #{dir_results} could not be read."
        false
      end
    end


    #########################################################
    # run_one
    #########################################################
    def run_one

    end


    #########################################################
    # run_all
    #########################################################
    def run_all

    end


    #########################################################
    # canonize_one
    #########################################################
    def canonize_one

    end


    #########################################################
    # canonize_all
    #########################################################
    def canonize_all

    end


  end # class TestRunner
  


  ########################################################################
  # class TidyRegressionCLI
  # This class provides handlers for CLI parameters.
  ########################################################################
  class TidyRegressionCLI < Thor

    include TidyRegressionTesting

    class_option :cases,
                 :banner => '<directory>',
                 :desc => 'Specifies the <directory> for canonical references.',
                 :aliases => '-c'

    class_option :results,
                 :banner => '<directory>',
                 :desc => 'Specifies the <directory> prefix to report results.',
                 :aliases => '-r'

    class_option :tidy,
                 :banner => '<path>',
                 :desc => 'Specifies the <path> to the Tidy executable to use.',
                 :aliases => '-t'

    class_option :notes,
                 :type => :boolean,
                 :desc => 'Indicates whether or not to display notes in reports.',
                 :aliases => '-n'

    class_option :verbose,
                 :type => :boolean,
                 :desc => 'Provides verbose output.',
                 :aliases => '-v'

    class_option :debug,
                 :type => :boolean,
                 :desc => 'Provides really, really verbose output.',
                 :aliases => '-d'


    #########################################################
    # help
    #  Override the default help in order to better describe
    #  what we're doing.
    #########################################################
    def help(*args)
      if args.count == 0
        test_runner = TestRunner.new
        set_options(test_runner)
        message_tidy = "version #{test_runner.tidy.version}"
        message_cases = File.exists?(test_runner.dir_cases) ? '' : '(directory not found; test will not run)'
        message_results = File.exists?(test_runner.dir_results) ? '(will try to use)' : '(will try to create)'
        puts <<-HEREDOC

This script (#{File.basename($0)}) is a Tidy regression testing script that can execute
every test in the suite, or optionally individual files. It also has the ability
to generate new benchmark files into the suite.

Default Locations:
------------------
  Tidy:    #{ test_runner.tidy.path }, #{ message_tidy }
  Cases:   #{ test_runner.dir_cases } #{ message_cases }
  Results: #{ test_runner.dir_results } #{ message_results }
  
You can also run this help command with the --tidy, --cases, and/or --results
options to test them, and check the results in the table above.

Complete Help:
--------------
        HEREDOC
      end

      super
    end

    #########################################################
    # rtest
    #  Tests a single file or all files, looking at the exit
    #  status, generated output, and error output.
    #########################################################
    desc 'rtest [<file>|<case_name>] [options]', 'Performs a regression test on <file> or <case_name>.'
    long_desc <<-LONG_DESC
      Will run a regression test for <file> or <case_name>. Use this command without
      <file> or <case_name> to run all of the regression tests. Output will be placed
      into the default directory unless an alternate is specified with --output.
      \n
      <case_name> indicates the filename portion between "case-" and the file extension.
      \n
      Pass/failure is based on matching all of the exit status, generated output,
      and error output.
    LONG_DESC
    def rtest(name = nil)

      set_options(nil)

      if name.nil?
        execution_ok = @regression.process_all(false)
      else
        execution_ok = @regression.process_one(name, false)
      end

      if execution_ok
        TidyTestRecord.make_report
        puts "\nThe test ended without any execution errors."
      else
        puts "\nThe test ended with one or more execution errors."
        puts "Try to run again with --verbose or --debug for details.\n\n"
      end

    end # rtest


    #########################################################
    # alltest
    #  Tests all files, looking only at the exit code.
    #########################################################
    desc 'alltest [options]', 'Performs a regression test on all test cases.'
    long_desc <<-LONG_DESC
      Will run a regression test on all test cases. Output will be placed
      into the default directory unless an alternate is specified with --output.
      \n
      Pass/failure is based on matching exit status only.
    LONG_DESC
    def alltest
    
    end # alltest
    
    desc 'testall [options]', 'A synonym for `alltest`.'
    long_desc <<-LONG_DESC
      Will run a regression test on all test cases. Output will be placed
      into the default directory unless an alternate is specified with --output.
      \n
      Pass/failure is based on matching exit status only.
      \n
      This command is simply a synonym for `alltest`.
    LONG_DESC
    def testall
      alltest    
    end # testall


    #########################################################
    # alltestc
    #  Tests all files, looking at the exit code and 
    #  comparing HTML output.
    #########################################################
    desc 'alltestc [options]', 'Performs a regression test on all test cases, comparing output.'
    long_desc <<-LONG_DESC
      Will run a regression test on all test cases. Output will be placed
      into the default directory unless an alternate is specified with --output.
      \n
      Pass/failure is based on matching exit status and HTML output.
    LONG_DESC
    def alltestc
    
    end # alltestc
    
    desc 'testallc [options]', 'A synonym for `alltestc`.'
    long_desc <<-LONG_DESC
      Will run a regression test on all test cases. Output will be placed
      into the default directory unless an alternate is specified with --output.
      \n
      Pass/failure is based on matching exit status and HTML output.
      \n
      This command is simply a synonym for `alltestc`.
    LONG_DESC
    def testallc
      alltestc 
    end # testallc
    
    
    #########################################################
    # onetest
    #  Tests one file, looking only at the exit code.
    #########################################################
    desc 'onetest [<file>|<case_name>] [options]', 'Performs a regression test on <file> or <case_name>.'
    long_desc <<-LONG_DESC
      Will run a regression test for <file> or <case_name>. Output will be placed
      into the default directory unless an alternate is specified with --output.
      \n
      Pass/failure is based on matching exit status only.
    LONG_DESC
    def onetest
    
    end # onetest
       

    #########################################################
    # canonize
    #  Writes the -expects.
    #########################################################
    option :replace,
           :type => :boolean,
           :desc => 'Indicates whether or not canonize replaces existing files.',
           :aliases => '-f'
    desc 'canonize [<file>|<case_name>] [options]', 'Builds expected output for <file> or <case_name>.'
    long_desc <<-LONG_DESC
      Will build the canonical output for <file> or <case_name> and put it into the default
      directory. Use without <file> or <case_name> to generate canonical reference material for
      all files. Use with --replace to force replacement of existing files.
      \n
      <case_name> indicates the filename portion between "case-" and the file extension.
    LONG_DESC
    def canonize(name = nil)

      set_options(nil)

      if name.nil?
        @regression.process_all(true)
      else
        @regression.process_one(name, true)
      end
      
      TidyTestRecord.make_canon_report

    end # canonize


    #########################################################
    # set_options( test_runner )
    #  Handles command line options.
    #########################################################
    protected
    def set_options( test_runner )
      test_runner.tidy.path = options[:tidy] unless options[:tidy].nil?
      test_runner.dir_cases = options[:cases] unless options[:cases].nil?
      test_runner.dir_results = options[:results] unless options[:results].nil?
      #test_runner.replace = options[:replace] unless options[:replace].nil?
      #test_runnershow_notes = options[:notes] unless options[:notes].nil?

      TidyRegressionTesting::log_level = Logger::WARN if options[:verbose]
      TidyRegressionTesting::log_level = Logger::DEBUG if options[:debug]
    end # set_options


  end # TidyRegressionCLI


end # TidyRegressionTesting


###########################################################
# Main
###########################################################

if __FILE__ == $0
  TidyRegressionTesting::TidyRegressionCLI.start(ARGV)
end
