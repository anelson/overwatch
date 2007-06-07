#!/usr/bin/env ruby

require 'overwatch'

# Wraps a <code>IO</code> object returned by <code>IO.popen</code>,
# monitoring for the EOF case then querying the exit code of the child
# process identified by <code>IO.pid</code>, throwing an error 
class WiresharkError < Exception
    def initialize(message)
        super
    end
end
