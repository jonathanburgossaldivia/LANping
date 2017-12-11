#!/usr/bin/ruby

require 'benchmark'
require 'ipaddr'
require 'net/ping'
require 'optparse'

def lanping
	options = {}
	OptionParser.new { |opts|
		opts.banner = "\n Usage: ruby LANping.rb [options] [arguments...]"
		opts.separator ""
		opts.version = "0.1"
		opts.on('-e', '--end IP', 'Ip to end the scan, default value is 255.') { |endip|
			options[:endip] = endip;}
		opts.on('-s', '--start IP', 'Ip to start the scan, default value is 1.') { |startip|
			options[:startip] = startip;}
		opts.on('-t', '--timeout SECONDS', "Timeout for end ping to the hosts, default value is 5.\n\n") { |timeouts|
			options[:timeouts] = timeouts;}
		begin
			opts.parse!
		rescue OptionParser::ParseError => error
			print "\n [!] #{error}\n [!] -h or --help to show valid options.\n\n"
			exit 1
		end
	}

	port = 7
	hilos = []
	levantado = []

	begin
		host = Socket.ip_address_list[4].ip_address     #Example variable value return'192.168.0.15'
	rescue
		print "\n Connection to the network is required.\n\n"
		exit 1
	end

	ip = host.split('.')[0..-2]                     #Variable is separated in 3 arrays "192","168","0"
	@iph = "#{ip[0]}."+"#{ip[1]}."+"#{ip[2]}."       #The arrays come together '192.168.0.'

	@startip = options[:startip].to_i
	@startip = 1 if @startip == 0

	@endip = options[:endip].to_i
	@endip = 255 if @endip == 0

	@timeouts = options[:timeouts].to_i
	@timeouts = 5 if @timeouts == 0

	print "\n LANping by Jonathan Burgos Saldivia > \n\n"
	(@startip..@endip).each { |j|
		hilos << Thread.new(j) do |j|
			ipc = "#{@iph}#{j}"
			mping = Net::Ping::External.new(ipc, port, @timeouts).ping?
			levantado.push(j) if mping == true
		end
	}

	hilos.each { |t| t.join }
	@sum = levantado.count
	puts " HOST".ljust(17) + "STATE".ljust(15) if @sum > 0 
	orden = levantado.sort
	orden.each { |u| puts " #{@iph}#{u}".ljust(17) + "up".ljust(15)}
end

tiempo = Benchmark.realtime {lanping}
print "\n Hosts scanned in: #{tiempo.round(2)} seconds | #{@sum} up | Range: #{@iph}#{@startip}-#{@endip} | Timeout: #{@timeouts}.\n\n"