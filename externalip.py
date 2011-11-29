'''
This script just finds your external IP address
Bugs and tickets, please email me: dev@rafalopes.com.br :)
'''

import urllib
import re

url = urllib.URLopener()
resp = url.open('http://myip.dk')
html = resp.read()

start = html.find('ha4')
end = start + 50

trim = html[start:end]
trim2=re.compile(u'(?P<ip>\d+\.\d+\.\d+\.\d+)').search(trim).groupdict()

print trim2['ip']
