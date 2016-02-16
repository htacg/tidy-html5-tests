#!/usr/bin/env ruby

###############################################################################
# Tidy Regression Test Suite - Unit Tests
#
###############################################################################

require_relative "trt.rb"
require 'test/unit'

################################################################
# Tests for `ModuleWhich`
################################################################
class TestModuleWhich < Test::Unit::TestCase

  # Ensure that Which::which can find a tidy executable.
  def test_which
    path = Which::which('tidy')
    assert_not_nil(path, 'Could not find tidy executable.')
  end

end # class TestModuleWhich


################################################################
# Tests for class `TidyExe`
################################################################
class TestClassTidyExe < Test::Unit::TestCase

  include TidyRegressionTesting
  
  def setup

  end
  
  def teardown
  
  end

  # Ensure basic functionality of our tidy versions.
  def test_versions
    tidy = TidyExe.new
    assert_not_nil(tidy.version, 'version returned nil.')
    assert_not_nil(tidy.version_major, 'version_major returned nil.')
    assert_not_nil(tidy.version_minor, 'version_minor returned nil.')
    assert_not_nil(tidy.version_patch, 'version_patch returned nil.')
    assert_not_nil(tidy.version_plain, 'version_plain returned nil.')
  end



end