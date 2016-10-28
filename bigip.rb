=begin

The BIG-IP system inserts a cookie into the HTTP response, by default, 
is named BIGipServer<pool_name> and the cookie value contains 
the encoded IP address and port of the destination server.

This behavior can cause disclose local IP address of Web Server.

Reference:

* https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

=end

begin

	cookie		 = ARGV[0].split(".") 
	encoded_ip   = cookie[0].to_i
	encoded_port = cookie[1].to_i

	begin

		ip 		= []
		port 	= []

		4.times do
			ip << encoded_ip%256
			encoded_ip /= 256
		end

		2.times do
			port << encoded_port%256
			encoded_port /= 256
		end

		puts "Local IP address found:\n"
		puts "\nIP Address : #{ip.join(".")}"
		puts "Port       : #{port[0]*256 + port[1]}"

	rescue

		puts "This is not Big-IP!"

	end

rescue

	puts "\n*** Error found! ***\n\nUsage this Big-IP decoder:\n\n  ruby bigip.rb [BIG-IP COOKIE VALUE]\n\nExample:\n\n  ruby bigip.rb 1677787402.36895.0000\n\n  IP Address : 10.33.70.12\n  Port       : 443"

end
