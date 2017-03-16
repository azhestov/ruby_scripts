#!/usr/bin/env ruby
require 'socket'
require 'ipaddr'

if ARGV.length != 2
    puts "Usage: ./server_udp.rb interface_name port"
    exit 255
end

inface = ARGV.first rescue 0
port = ARGV.last rescue 0

if inface == 0
    puts "Incorrect inteface"
    exit 254
end

if port == 0
    puts "Incorrect port"
    exit 253
end

SIOCGIFADDR    = 0x8915

def ip_address(iface)
    sock = UDPSocket.new
    buf = [iface,""].pack('a16h16')
    sock.ioctl(SIOCGIFADDR, buf);
    sock.close
    buf[20..24].unpack("CCCC").join(".")
end

listip = ip_address(inface)
hostname = Socket.gethostname


sock = UDPSocket.new
sock.bind(listip, port)
        loop{
        text,sender = sock.recvfrom(512)
        sock.send(text,0,sender[3],sender[1])
        }
