#!/usr/bin/env ruby

# Runs all the tests
Dir['**/*_test.rb'].each { |test_case| require test_case }

