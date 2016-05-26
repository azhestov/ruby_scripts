#!/usr/bin/ruby

if ARGV.count < 1 
	puts "Arguments missed"
	puts "Usage: parser.rb nginx_access_log_filename [HTTP response code position] [request time position]"
	puts "If you not shure - add filename only and follow instructions"
	exit 255
end

$filename = ARGV[0]
$response_pos = ARGV[1]||''
$rtime_pos = ARGV[2]||''

if not File.exist?($filename)
puts "File #{$filename} not found"
exit 255
end

if $response_pos.empty? or $rtime_pos.empty?

while  $response_pos.empty?
	httpcodes = File.readlines($filename).first
	codescan=httpcodes.scan(/(\[[^\[]\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)
	codescan.each do |code| 
		code.each(&:lstrip!) 
		code.each { |p| p.tr!('"','')}
	end
	$lengh = codescan.count - 1
	
	puts `clear`
	puts "enter HHTP response code position\n\n"
	codescan.each_with_index { |code, ind| puts "#{ind}:\t#{code.shift.strip}" }
	$response_pos = STDIN.gets.chomp
	$rp = Integer($response_pos) rescue nil
	case $rp
	 when 0..$lengh
		break
	 else 
		$response_pos = ''
	end
end

while  $rtime_pos.empty? or $rt == $rp
	httpcodes = File.readlines($filename).first
	codescan=httpcodes.scan(/(\[[^\[]\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)
	codescan.each do |code| 
		code.each(&:lstrip!) 
		code.each { |p| p.tr!('"','')}
	end
	$lengh = codescan.count 
	
	puts `clear`
	puts "enter request time position\n\n"
	codescan.each_with_index { |code, ind| puts "#{ind}:\t#{code.shift.strip}" }
	$rtime_pos = STDIN.gets.chomp
	$rt = Integer($rtime_pos) rescue nil
	if $rt != $rp
		case $rt
			when 0..$lengh
			break
	 	else 
			$rtime_pos = ''
		end
	else
		$rtime_pos = ''
	end
end

end #if

fields = Array.new()

File.readlines($filename).each do |line|

	linescan=line.scan(/(\[[^\[]\]|"[^"]+"|^\S+|\s[^"\[\s]+)/)

	linescan.each do |l|
		l.each(&:lstrip!)
		l.each { |p| p.tr!('"','')}
	end
	#puts "#{line}"
        c = linescan.at(5)
	if c.last == "200"
		fields.push(linescan[9]) 
	end
end

$c = fields.count.to_i
f = fields.sort
l = f.last
$c25 = $c * 0.25
$c50 = $c * 0.50
$c75 = $c * 0.75
$c95 = $c * 0.95
i25 = f.at($c25)
i50 = f.at($c50)
i75 = f.at($c75)
i95 = f.at($c95)
puts "\nTotal count of HTTP200 is - #{$c95.to_i} from #{$c}.\n\n"
puts "95% percentile is #{i95.last} msec"
puts "75% percentile is #{i75.last} msec"
puts "50% percentile is #{i50.last} msec"
puts "25% percentile is #{i25.last} msec"
puts "\nMax response time is #{l.last} msec\n\n"
