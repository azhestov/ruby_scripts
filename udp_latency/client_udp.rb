#!/usr/bin/env ruby
require 'socket'
require 'ipaddr'

if ARGV.length != 2
    puts "Usage: ./client_udp.rb host port"
    exit 255
end

host = ARGV.first rescue 0
port = ARGV.last rescue 0

if host == 0
    puts "Incorrect host"
    exit 254
end

if port == 0
    puts "Incorrect port"
    exit 253
end
counter = Time.now.to_i
u2 = UDPSocket.new
u2.connect(host,port)
fork do
        $0 = 'cludp recv'
        STDOUT.sync = true
        loop {
                text,sender = u2.recvfrom(512)
                start, seq = text.split
                latency = 1000 * ( Time.now.to_f - start.to_f)
                printf("%s %10.4f %010d\n", Time.now.strftime('%F %T'), latency, seq)
        }
end

$0 = 'cludp sender %s %s' % [host, port]

loop {
        epoch = Time.now.to_f
        sping = epoch.to_s + " " + counter.to_s
        u2.send sping, 0
        counter += 1
        sleep 0.5
}
