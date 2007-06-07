#!/usr/bin/env ruby

# Test fixture for the PDMLExtractor class
require File.dirname(__FILE__) + '/test_helper.rb'
require 'rexml/document'

class TestPDMLExtractor < Test::Unit::TestCase
    include TestHelper

    def test_globals
        assert_not_nil(PDMLExtractor.tshark_path)
    end        

    def test_command_line
        extractor = PDMLExtractor.new('whatever.cap')

        assert(extractor.command_line.include?(PDMLExtractor.tshark_path))
    end

    def test_nonexistent_cap_file
        my_assert_exception_raised(WiresharkError) {
            extractor = PDMLExtractor.new('nonexistentcapfile.cap')
            extractor.start
        }
    end

    def test_stream
        extractor = PDMLExtractor.new(get_test_data_path('test.cap'))

        pipe = extractor.start

        assert_not_nil(pipe)

        # pipe should be a valid XML document containing zero or more <packet>
        # elements.  Use REXML to find out
        doc = REXML::Document.new(pipe)

        element_count = 0

        assert doc.elements.each("//packet") { |element| element_count += 1 }

        assert element_count > 0, "XML stream from PDMLExtractor doesn't include any <packet> elements"
    end
end

