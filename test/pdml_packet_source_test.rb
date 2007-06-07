#!/usr/bin/env ruby

# Test fixture for the PDMLExtractor class
require File.dirname(__FILE__) + '/test_helper.rb'

require 'stringio'

require File.dirname(__FILE__) + '/pdml_packet_source_test_cruft'

class TestPDMLPacketSource < Test::Unit::TestCase
    include TestHelper

    def test_empty_stream
        # NB: REXML doesn't like zero-length streams, as it assumes it can read at least two bytes
        # to detect the encoding
        input = StringIO.new("     ")

        source = PDMLPacketSource.new(input)
        listener = PDMLPacketSourceTestCruft::TestPDMLPacketSourceListener.new()

        source.add_observer(listener)

        source.parse_stream

        assert_equal(0, listener.notifications)
    end

    def test_no_packets_stream
        listener = PDMLPacketSourceTestCruft::TestPDMLPacketSourceListener.new()
        parse_pdml_test_data("no_packets.pdml", listener)

        assert_equal(0, listener.notifications)
    end

    def test_error_in_stream
        my_assert_exception_raised(REXML::ParseException) {
            listener = PDMLPacketSourceTestCruft::TestPDMLPacketSourceListener.new()
            parse_pdml_test_data("invalid.pdml", listener)
        }
    end

    def test_single_wlan_packet_in_stream
        listener = PDMLPacketSourceTestCruft::TestPDMLPacketSourceListener.new()
        parse_pdml_test_data("single_wlan_packet.pdml", listener)

        assert_equal(1, listener.notifications)

        packet = listener.packets.first

        # Run a few XPath queries to make sure this is what's expected
        ssid_tag_num_field = packet.elements["//field[@name='wlan_mgt.tag.number' and @show='0']"]
        assert_not_nil(ssid_tag_num_field)

        ssid_tag_interp_field = ssid_tag_num_field.parent.elements["field[@name='wlan_mgt.tag.interpretation']"]
        assert_not_nil(ssid_tag_interp_field)

        ssid = ssid_tag_interp_field.attributes["show"]

        assert_equal("no_wires", ssid)

        number = packet.elements["/packet/proto[@name='geninfo']/field[@name='num']"].attributes["value"]

        assert_equal("1", number)
    end

    def test_complex_dump_performance
        listener = PDMLPacketSourceTestCruft::TestNullPDMLPacketSourceListener.new()
        parse_pdml_test_data("big_dump.pdml", listener)
    end

    def parse_pdml_test_data(name, listener)
        load_test_data(name) do |pipe|
            source = PDMLPacketSource.new(pipe)
            source.add_observer(listener)
            source.parse_stream
        end
    end
end


