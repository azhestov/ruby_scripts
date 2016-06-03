#!/usr/bin/ruby
require "zlib"

#checks
if (ARGV.count < 1 || ARGV[0] == "-h" || ARGV[0] == "--help") 
	puts "Usage: nginx_parslog.rb access_log_filename [HTTP response code position] [request time position]"
	puts "If you not shure - add filename only and follow instructions"
	exit(254)
end

$filename = ARGV[0]
$response_pos = ARGV[1]||''
$rtime_pos = ARGV[2]||''

if not File.exist?($filename)
	puts "File #{$filename} not found"
	exit(255)
end

#mime-type hack
filetype = `file --brief --mime-type #{$filename}`.chomp
#read first line
case filetype
when "text/plain"
	field_values = File.readlines($filename).first
when "application/gzip"
	infile = File.open($filename)
	gz = Zlib::GzipReader.new(infile)
	field_values = gz.readline
	gz.close
else
	puts "Wrong file format"
	exit(250)
end

#scan first line and parsing
$codescan=field_values.scan(/(\[[^\[]+\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)
$codescan.each do |code| 
	code.each(&:lstrip!) 
	code.each { |p| p.tr!('"','')}
end
$codescan.flatten!
$lengh = $codescan.length

#check arguments values
$rop = Integer($response_pos) rescue nil
$rot = Integer($rtime_pos) rescue nil

if ($rop == nil || $rot == nil)
	puts "unknown arguments format, use number values"
	exit(253)
end
if $rop >= $lengh
	puts "$status field can't be more #{$lengh-1}"
	exit(253)
end
if $rot >= $lengh
	puts "$request_time field can't be more #{$lengh-1}"
	exit(253)
end
if $rot == $rop
	puts "$status field can't be equal $request_time"
	exit(253)
end


#if not all arguments
prompt = '>'
if $response_pos.empty? or $rtime_pos.empty?

	while  $response_pos.empty?
		puts `clear`, "\n\n"
		$codescan.each_with_index { |code, ind| puts "#{ind}:\t#{code}" }
		puts "\nenter HHTP response code position\n\n"
		print prompt
		$response_pos = STDIN.gets.chomp
		$rp = Integer($response_pos) rescue nil
		case $rp
	 	when 0...$lengh
		else 
			$response_pos = ''
		end
	end

	while  $rtime_pos.empty? or $rt == $rp
		puts `clear`, "\n\n"
		$codescan.each_with_index { |code, ind| puts "#{ind}:\t#{code}" }
		puts "\nenter request time position\n\n"
		print prompt
		$rtime_pos = STDIN.gets.chomp
		$rt = Integer($rtime_pos) rescue nil
		case $rt
		when 0...$lengh
	 	else
			$rtime_pos = ''
		end
	end

end


#scan log file

$fields = Array.new()

def scan_line(line)
	linescan=line.scan(/(\[[^\[]+\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)
	linescan.each do |l|
		l.each(&:lstrip!)
		l.each { |p| p.tr!('"','')}
	end
        c = linescan.at($response_pos.to_i)
	if c.last == "200"
		$fields.push(linescan[$rtime_pos.to_i]) 
	end
end
t = 0
case filetype
when "text/plain"
	#content = File.open($filename)
	File.readlines($filename).each do |l|
		scan_line(l)
	t = t + 1
	end
when "application/gzip"
	zipfile = File.open($filename)
	gz = Zlib::GzipReader.new(zipfile)
	gz.each_line do |l|
		scan_line(l)
	t = t + 1
	end
	gz.close
else
	puts "Wrong file format"
	exit(250)
end


#calculate values

c = $fields.length
f = $fields.sort
l = f.last
perc = [25,50,75,95]
puts "\nTotal count of HTTP200 is - #{c} from #{t}.\n\n"
for i in perc do
	ou = f.at((c*i/100))
	puts "#{i}% percentile is #{ou.last} msec"
end
puts "\nMax response time is #{l.last} msec\n\n"
