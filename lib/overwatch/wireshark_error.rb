#!/usr/bin/env ruby

require "overwatch"

# Represents an error reported by the Wireshark binaries
class WiresharkError < Exception
    def initialize(command_line, message)
        super "Error from [#{command_line}]: #{message}"
    end
end
