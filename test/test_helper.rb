#!/usr/bin/env ruby

require 'test/unit'

require File.dirname(__FILE__) + '/../lib/overwatch.rb'

module TestHelper
    include Test::Unit::Assertions

    TEST_DATA_PATH = File.dirname(__FILE__) + "/testdata"

    def load_test_data(name)
        File.open(get_test_data_path(name), "r") do |file| 
            yield file
        end
    end

    def get_test_data_path(name)
        TEST_DATA_PATH + "/" + name
    end

  # Asserts that a block raises an exception.  Stolen from Ross Niemi 
  # at http://rossniemi.wordpress.com/2007/01/31/learning-ruby-tdd-style-part-2/
  def my_assert_exception_raised expected
    begin
      yield
      exceptionNotRaised = true
    rescue Exception => exception
      my_assert_type_of expected, exception
    end

    if exceptionNotRaised
      raise Test::Unit::AssertionFailedError.new(
        "#{expected} should have been raised.")
    end
  end

  # Other assertion helpers stolen from Ross Niemi as well
   def my_assert_type_of expectedClass, actualInstance
    my_assert_not_nil actualInstance
    my_assert_classes_are_equal nil, nil
    my_assert_classes_are_equal actualInstance.class, actualInstance.class
    my_assert_classes_are_equal expectedClass, expectedClass
    my_assert_classes_are_equal expectedClass, actualInstance.class
  end

  def my_assert_not_nil instance
    assert instance
    assert !instance.nil?
    assert instance != nil
  end

  def my_assert_classes_are_equal clazz1, clazz2
    assert clazz1.eql?(clazz2), "Expected class #{clazz1}, got class #{clazz2}"
    assert clazz1.equal?(clazz2), "Expected class #{clazz1}, got class #{clazz2}"
    assert clazz1 == clazz2, "Expected class #{clazz1}, got class #{clazz2}"
  end
end

