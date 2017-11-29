#!/usr/bin/ruby

require 'ipaddr'
require 'net/ping'
require 'optparse'

class String
	def bold_yellow; colorize(self, "\e[1m\e[33m"); end
	def bold_blue; colorize(self, "\e[1m\e[34m"); end
	def std_bg; colorize(self, "\e[1m\e[7m"); end
	def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end

options = {}

OptionParser.new do |opts|
	opts.banner = "\n Usage: ruby LANping.rb [options] [arguments...]"
	opts.separator ""
	opts.version = "0.1"
	opts.on('-s', '--start IP', 'Ip to start the scan, default value is 1.') do |startip|
		options[:startip] = startip;
	end
	opts.on('-e', '--end IP', 'Ip to end the scan, default value is 255.') do |endip|
		options[:endip] = endip;
	end
	opts.on('-t', '--timeout SECONDS', 'Timeout for end ping to the hosts, default value is 1.') do |timeouts|
		options[:timeouts] = timeouts;
	end
	begin
		opts.parse!
	rescue OptionParser::ParseError => error
		puts ""
		$stderr.puts " [!] #{error}"
		$stderr.puts " [!] -h or --help to show valid options."
		exit 1
	end
end

sum = 0
port = 443
hilos = []

begin
	host = Socket.ip_address_list[4].ip_address     #Example variable value return'192.168.0.15'
rescue
	print "\n Connection to the network is required.\n"
	exit 1
end

ip = host.split('.')[0..-2]                     #Variable is separated in 3 arrays "192","168","0"
iph = "#{ip[0]}."+"#{ip[1]}."+"#{ip[2]}."       #The arrays come together '192.168.0.'

startip = options[:startip].to_i
if startip == 0
	startip = 1
end

endip = options[:endip].to_i
if endip == 0
	endip = 255
end

timeouts = options[:timeouts].to_i
if timeouts == 0
	timeouts = 1
end

print "\n " + "Tool by Jonathan Burgos Saldivia >".std_bg.bold_yellow + "\n"
puts ""
for i in startip..endip do
	hilos << Thread.new(i) do |j|
		ipc = "#{iph}#{j}"
		mping = Net::Ping::External.new(ipc, port, timeouts).ping?	
		if mping
			print " [+]".bold_blue + " Host up: #{ipc}\n".bold_yellow
			sum+= 1
		end
	end
end

hilos.each do |p|
	p.join
end

print "\n [!]".bold_blue + " Hosts up: #{sum} | Range: #{startip}-#{endip} | Timeout: #{timeouts}.\n".bold_yellow