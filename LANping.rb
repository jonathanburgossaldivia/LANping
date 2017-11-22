#!/usr/bin/ruby

require 'socket'

sum = 0
hilos = []
host = Socket.ip_address_list[4].ip_address #Example variable value return'192.168.0.15'
ip = host.split('.')[0..-2] #Variable is separated in 3 arrays "192","168","0"
iph = "#{ip[0]}."+"#{ip[1]}."+"#{ip[2]}." #The arrays come together '192.168.0.'

puts ""
puts "Tool by Jonathan Burgos Saldivia >"
puts ""
for i in 1..255 do
	hilos << Thread.new(i) do |j|
		ping = system("ping -q -W 5 -c 1 #{iph}#{j}", [:err, :out] => "/dev/null")
		if ping
		print "[+] Host up #{iph}#{j}\n"
		sum+= 1
	else
		next
		end
	end
end

hilos.each do |t|
	t.join
end
puts ""
print "[!] Done! | Total host up in the network: #{sum}.\n"