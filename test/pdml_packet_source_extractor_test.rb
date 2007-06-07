#!/usr/bin/env ruby

# Tests the integration of PDMLPacketSource and PDMLExtractor to extract packets from a 
# pcap-compatible capture file
require File.dirname(__FILE__) + '/test_helper.rb'

require File.dirname(__FILE__) + '/pdml_packet_source_test_cruft'


class TestPDMLPacketSourceAndExtractor < Test::Unit::TestCase
    include TestHelper

    def test_cap_parse_load
        listener = PDMLPacketSourceTestCruft::TestNullPDMLPacketSourceListener.new()
        extractor = PDMLExtractor.new(get_test_data_path('test.cap'))
        pipe = extractor.start
        source = PDMLPacketSource.new(pipe)
        source.add_observer(listener)
        source.parse_stream

        assert listener.notifications > 0, "Loading test.cap didn't produce any packet notifications"
    end

    def test_huge_cap_parse_load
        listener = PDMLPacketSourceTestCruft::TestNullPDMLPacketSourceListener.new()
        extractor = PDMLExtractor.new(get_test_data_path('huge_dump.cap'))
        pipe = extractor.start
        source = PDMLPacketSource.new(pipe)
        source.add_observer(listener)
        source.parse_stream

        assert listener.notifications > 0, "Loading test.cap didn't produce any packet notifications"
    end

end
