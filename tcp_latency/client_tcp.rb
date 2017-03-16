#!/usr/bin/env ruby           
require 'logger'
require 'socket'


if ARGV.length != 2
    puts "Usage: ./client_tcp.rb hostname port"
    puts "(start remote server first)"
    exit 255
end

broker = Socket.gethostbyname(ARGV.first)[0] rescue 0
port = ARGV.last rescue 0

if broker == 0
    puts "Incorrect hostname"
    exit 254
end

if port == 0
    puts "Incorrect port"
    exit 253
end

logger = Logger.new("/var/log/#{broker}-remote.log")
TCPSocket.open(broker, port){ |client|
client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) 
    loop{
    client.puts Time.now.to_f
    latency = *client.gets.chomp
    logger.info "latency #{"%10.2f" % (1000.0 * (Time.now.to_f - latency.at(0).to_f))} millisec"
    sleep(0.5)
    }                                
   logger.close
}
