#!/usr/bin/env ruby

module PDMLPacketSourceTestCruft
    # Listens to a PDMLPacketSource's notifications and saves all packets received
    class TestPDMLPacketSourceListener
        
        def initialize
            @notifications = 0
            @packets = []
        end

        def update(packet)
            @notifications += 1
            @packets << packet
        end    

        def notifications
            @notifications
        end

        def packets
            @packets
        end
    end

    # Listens to a PDMLPacketSource and counts (but doesn't save) packets 
    class TestNullPDMLPacketSourceListener
        
        def initialize
            @notifications = 0
        end

        def update(packet)
            @notifications += 1
        end    

        def notifications
            @notifications
        end

    end
end
