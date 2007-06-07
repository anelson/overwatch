#!/usr/bin/env ruby

require "overwatch"

=begin rdoc
Wraps <code>tshark</code>, the command-line version of <code>wireshark</code>, to product
a stream of PDML for all the packets within a capture file
=end
class PDMLExtractor
    def initialize(capfile)
        @capfile = capfile
    end

    # The path to the tshark executable
    def PDMLExtractor.tshark_path
        # FIXME: Assumes tshark is in the PATH
        return '"C:/Program Files/Wireshark/tshark"'
    end

    # The tshark command line which will be used to produce the PDML stream
    def command_line
         "#{PDMLExtractor.tshark_path} -r #{@capfile} -T pdml 2>&1"
    end

    # Starts a new tshark process to dump the PDML, and returns a pipe
    # which will provide access to the stream of PDML markup
    def start
        pipe = IO.popen(command_line)

        # If the command line was valid and things are working, the first
        # thing we'll see from tshark is <?xml version=...., otherwise something else
        # check for that now
        raise WiresharkError.new(command_line, "The command did not produce any output") if pipe.eof

        output = pipe.readline
        if output.index("<?xml version=") != 0
            # Read entire output until EOF, then throw an exception with the resulting output
            pipe.readlines.each {|line| output << line << $/}

            raise WiresharkError.new(command_line, output)
        end

        # First line was the XML preamble.  Don't care about that in the parser anyway, so 
        # let it go
        return pipe
    end
end
