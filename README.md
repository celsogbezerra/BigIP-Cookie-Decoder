# BigIP Cookie Decoder

The BIG-IP system inserts a cookie into the HTTP response, by default, is named BIGipServer<pool_name> and the cookie value contains the encoded IP address and port of the destination server.

This behavior can cause disclose local IP address of Web Server.

Reference:

* https://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

# Usage:

ruby bigip.rb [-h] [-u URL_TARGET] [-d BIGIP_COOKIE_VALUE]

# Options:

-d    Decode the cookie value.
-h    Print a summary of the usage.
-u    Get the BIGip value in target and decode.

# Examples:

guest@hostname:~$ ruby bigip.rb -d 1677787402.36895.0000

IP address found:

IP Address : 10.33.70.12
Port       : 443

guest@hostname:~$ ruby bigip.rb -u https://example.com/

BIGip cookie: 1677787402.36895.0000

IP address found:

IP Address : 10.33.70.12
Port       : 443
