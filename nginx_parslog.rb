#!/usr/bin/ruby
require "zlib"

#checks
if (ARGV.count < 1|| ARGV.count > 3 || ARGV[0] == "-h" || ARGV[0] == "--help") 
	puts "Usage: nginx_parslog.rb access_log_filename [HTTP response code position] [request time position]"
	puts "If you not shure - add filename only and follow instructions"
	exit(254)
end

$filename = ARGV[0]
$response_pos = ARGV[1]||''
$rtime_pos = ARGV[2]||''

unless File.exist?($filename)
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
REG_SCAN=/(\[[^\[]+\]|"[^"]+"|^\S+|\s[^"\[\s]+)/
$codescan=field_values.scan(REG_SCAN)
$codescan.each do |code|
	 code.each(&:lstrip!)
	 code.each{|p| p.tr!('"','')}
end	
$codescan.flatten!
$lengh = $codescan.length

#check arguments values

def check_arg(b)
	unless b.nil?
		a = Integer(b) rescue nil
		if a.nil?
			puts "unknown arguments format, use number values, or just file name"
			exit(253)
		end
	end
	return a
end

unless ARGV.count == 1
$rp = check_arg($response_pos)
$rt = check_arg($rtime_pos)

	if $rp >= $lengh
		puts "$status field can't be more #{$lengh-1}"
		exit(253)
	end
	if $rt >= $lengh
		puts "$request_time field can't be more #{$lengh-1}"
		exit(253)
	end
	if $rt == $rop
		puts "$status field can't be equal $request_time"
		exit(253)
	end
end

	puts "rot=#{$rt} rop=#{$rp}"
def read_console(message)
	a = ''
	status = ''
	while a == ''
		#puts `clear`, "\n\n"
	        $codescan.each_with_index { |code, ind| puts "#{ind}:\t#{code}" }
	        puts "#{status}\n#{message}\n\n"
	        print '>'
	        answer = STDIN.gets.chomp
	        a = Integer(answer) rescue nil
		unless (0...$lengh) === a
			status = 'Error number. '
			a = ''
		end
	end
	return a
end

if ARGV.count.to_i == 1 
	$rp = read_console("enter HHTP response code position")
	puts "rot=#{$rt} rop=#{$rp}"
	until  $rt == $rp
	puts "rtot=#{$rt} rop=#{$rp}"
		$rt = read_console("enter request time position")
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
        c = linescan.at($rp.to_i)
	if c.last == "200"
		$fields.push(linescan[$rt.to_i]) 
	end
end
t=0
case filetype
when "text/plain"
	#content = File.open($filename)
	File.readlines($filename).each do |l|
		scan_line(l)
	t=t+1
	end
when "application/gzip"
	zipfile = File.open($filename)
	gz = Zlib::GzipReader.new(zipfile)
	gz.each_line do |l|
		scan_line(l)
	t=t+1
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
