# BigIP-Cookie-Decoder

The BIG-IP system inserts a cookie into the HTTP response, by default, is named BIGipServer<pool_name> and the cookie value contains the encoded IP address and port of the destination server.

This behavior can cause disclose local IP address of Web Server.

Reference:

* https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html


# Usage this Big-IP decoder:

   ruby bigip.rb [BIG-IP COOKIE VALUE]

# Example:

   ruby bigip.rb 1677787402.36895.0000

   IP Address : 10.33.70.12
   Port       : 443"