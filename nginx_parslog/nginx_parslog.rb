#!/usr/bin/ruby

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

#scan first line and parsing

field_values = File.readlines($filename).first
$codescan=field_values.scan(/(\[[^\[]+\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)
$codescan.each do |code| 
	code.each(&:lstrip!) 
	code.each { |p| p.tr!('"','')}
end
$codescan.flatten!
$lengh = $codescan.length


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

fields = Array.new()

#scan log file

File.readlines($filename).each do |line|

	linescan=line.scan(/(\[[^\[]+\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)

	linescan.each do |l|
		l.each(&:lstrip!)
		l.each { |p| p.tr!('"','')}
	end
        c = linescan.at($response_pos.to_i)
	if c.last == "200"
		fields.push(linescan[$rtime_pos.to_i]) 
	end
end

#calculate values

c = fields.length
f = fields.sort
l = f.last
perc = [25,50,75,95]
puts "\nTotal count of HTTP200 is - #{(c*0.95).to_i} from #{c}.\n\n"
for i in perc do
	ou = f.at((c*i/100))
	puts "#{i}% percentile is #{ou.last} msec"
end
puts "\nMax response time is #{l.last} msec\n\n"
