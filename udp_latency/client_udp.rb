#!/opt/chef/embedded/bin/ruby

#!/usr/bin/env ruby
require 'socket'
require 'ipaddr'

if ARGV.length != 2
    puts "Usage: ./client.rb host port"
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
#counter = 0
#u2 = UDPSocket.new
#u2.connect(host,port)
#loop {
#epoch = Time.now.to_f
#sping = epoch.to_s + " " + counter.to_s
#u2.send sping, 0
#text,sender = u2.recvfrom(512)
#answer = text.split
#latency = 1000 * ( Time.now.to_f - answer[0].to_f)
#p Time.now.strftime("%Y-%m-%d %H:%M:%S") + " #{"%10.4f" % (latency.to_s)} #{"%10.10d" % (answer[1].to_s)}"
#sleep 1
#counter += 1
#}

u2 = UDPSocket.new
u2.connect(host,port)
fork do
        $0 = 'cludp recv'
        STDOUT.sync = true
#       puts 'In a child'
#u2.bind(listip, 623)
        loop {
                text,sender = u2.recvfrom(512)
#               text = u2.read
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
