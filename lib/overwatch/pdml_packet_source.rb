#!/usr/bin/env ruby

require 'observer'
require 'rexml/document'
require 'rexml/element'

require "overwatch"

=begin rdoc
Parses a stream of PDML, and notifies listeners with each complete packet in the stream

Implements the Observable pattern; listeners can be registered with add_observer.
Listeners must implement the update message, which takes as its argument the packet from
the stream.  PDML packets take the form of RE XML document objects, with <code>packet</code>
as the root element.

Under the covers, implements a StreamListener which gathers events from the REXML parser, and congeals
them into complete PDML packets
=end
class PDMLPacketSource
    include Observable

    # Constructs a new PDMLPacketSource instance, using the specified IO pipe as its PDML source
    def initialize(pipe)
        @pipe = pipe

        @element_stack = []
    end

    # Parses the contents of the stream, notifying the observers when a complete PDML packet 
    # is encountered
    def parse_stream()
        #puts "parse_stream"
        REXML::Document.parse_stream(@pipe, self)
    end

    # Creates a new REXML Element object and pushes it onto the stack
    def start_new_element(name, attrs)
        parent = @element_stack.last

        #puts "Adding element '#{name}' to '#{parent.name}'"

        child = REXML::Element.new(name, parent)
        child.add_attributes(attrs)

        @element_stack.push(child)
    end

    # StreamListener impl begins here

    # Called when a tag is encountered.
    def tag_start(name, attrs)

        #puts "<#{name}>"
        if (name == "packet")
            # Start of a new packet
            @element_stack = [REXML::Document.new()]
        end

        # If there's nothing on the element stack yet, that means
        # we've yet to encounter a <packet> element, so there's no point
        # in proceeding
        return unless @element_stack.length > 0

        # Start a new element and push it onto the stack
        start_new_element(name, attrs)
    end

    # Called when the end tag is reached.  In the case of <tag/>, tag_end
    # will be called immidiately after tag_start
    def tag_end(name)
        #puts "</#{name}>"
        # Do nothing unless we're currently working on a <packet> element or one of its children
        return unless @element_stack.length > 0

        # This should match the element on the top of the stack
        elem = @element_stack.pop

        if elem.name != name
            raise ArgumentError, "End tag #{name} doesn't match most recent element, #{elem.name}"
        end

        if name == "packet"
            # A packet is done
            changed(true)
            notify_observers(elem)
            @element_stack = []
        end
    end

    # Called when text is encountered in the document
    # @p text the text content.
    def text(text)
        # Do nothing unless we're currently working on a <packet> element or one of its children
        return unless @element_stack.length > 0

        @element_stack.last.add_text(text)
    end

    # Called when an instruction is encountered.  EG: <?xsl sheet='foo'?>
    def instruction(name, instruction)
        # Do nothing unless we're currently working on a <packet> element or one of its children
        return unless @element_stack.length > 0

        @element_stack.last.add(Instruction.new(name, instruction))
    end

    # Called when a comment is encountered.
    def comment(comment)
        # Do nothing unless we're currently working on a <packet> element or one of its children
        return unless @element_stack.length > 0

        @element_stack.last.add(Comment.new(comment))
    end

    # Handles a doctype declaration. 
    def doctype(name, pub_sys, long_name, uri)
        # Don't care about doctypes
    end

    # Called when the doctype is done
    def doctype_end
        # Don't care about doctypes
    end

    def attlistdecl element_name, attributes, raw_content
    end

    # <!ELEMENT ...>
    def elementdecl content
        # Don't care
    end

    def entitydecl content
        # Don't care
    end

    # <!NOTATION ...>
    def notationdecl content
        # Don't care
    end

    # Called when %foo; is encountered in a doctype declaration.
    def entity content
        # Don't care
    end

    # Called when <![CDATA[ ... ]]> is encountered in a document.
    def cdata(content)
        # Do nothing unless we're currently working on a <packet> element or one of its children
        return unless @element_stack.length > 0

        @element_stack.last.add(CData.new(content))
    end

    # Called when an XML PI is encountered in the document.
    # EG: <?xml version="1.0" encoding="utf"?>
    def xmldecl(version, encoding, standalone)
        # Do nothing unless we're currently working on a <packet> element or one of its children
        return unless @element_stack.length > 0

        @element_stack.last.add(Instruction.new("xml", "version=\"#{version}\" encoding=\"#{encoding}\" standalone=\"#{standalone}\""))
    end
end

