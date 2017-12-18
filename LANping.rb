#!/usr/bin/ruby

require 'benchmark'
require 'ipaddr'
require 'net/ping'
require 'optparse'
require 'timeout'

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
	opts.on('-t', '--timeout SECONDS', "Timeout for end ping to the hosts, default value is 1.\n\n") do |timeouts|
		options[:timeouts] = timeouts;
	end
	begin
		opts.parse!
	rescue OptionParser::ParseError => error
		puts "\n [!] #{error}\n [!] -h or --help to show valid options.\n\n"
		exit 1
	end
end

begin
	host = Socket.ip_address_list[4].ip_address
rescue
	print "\n Connection to the network is required.\n\n"
	exit 1
end

@mi_array = Array.new
@mi_array1 = Array.new
@mi_hash = Hash.new
@n_fin = 128.to_i
@numero_hilo = 1.to_i
@cantidad = 0
@ip = host.split('.')[0..-2]
@iph = "#{@ip[0]}."+"#{@ip[1]}."+"#{@ip[2]}."
@startip = options[:startip].to_i
@startip = 1 if @startip == 0
@inicio = @startip
@endip = options[:endip].to_i
@endip = 255 if @endip == 0
@fin = @inicio + @n_fin
@range = @endip - @startip
@fin  = @range + 1 if @range < 51
@fin2 = @range + @inicio
@timeouts = options[:timeouts].to_i
@timeouts = 1 if @timeouts == 0

print "\n" + " LANping ipv4 v0.2 by Jonathan Burgos Saldivia >\n\n"
print " HOST".ljust(17) +"STATE".ljust(7) +"TIME".ljust(8) +"\n" 

def lanping
	while @numero_hilo < @range
		(@inicio..@fin).each { |i|
			@mi_array << Thread.new(i) { |i|
				time= Benchmark.realtime { 
				ipc = "#{@iph}#{i}"
				@mping = Net::Ping::External.new(ipc, 7, @timeouts).ping?
				}.round(3)
				if @mping
					@mi_hash [:"#{i}"]  = "#{time}" if i <= @fin2
				end
				@numero_hilo += 1
			}
		}
		@inicio += @n_fin.to_i
		@fin += @n_fin.to_i
		@mi_array.each { |t| t.join}
		salida = @mi_hash.sort
		@cantidad += @mi_hash.count
		salida.each { |key, value| print " #{@iph}#{key}".ljust(17)+"UP".ljust(7) +"#{value}".ljust(8) +"\n" }
		@mi_hash.clear
	end
end

tiempo = Benchmark.realtime {lanping}.round(3)
print "\n Found #{@cantidad} host(s) in #{tiempo} seconds | Range: #{@startip}-#{@endip} | Timeout: #{@timeouts}.\n\n"