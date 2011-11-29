'''
This script just finds your external IP address
Bugs and tickets, please email me: dev@rafalopes.com.br :)
'''

import urllib
import re

url = urllib.URLopener()
resp = url.open('http://myip.dk')
html = resp.read()

start = html.find('ha4') #watch this line if the script stops working
end = start + 50

trim = html[start:end]
trim=re.compile(u'(?P<ip>\d+\.\d+\.\d+\.\d+)').search(trim).groupdict()

print trim['ip']
