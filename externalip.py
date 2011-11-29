'''
Finds your external IP address
'''

import urllib
import re

def get_ip():
    group = re.compile(u'(?P<ip>\d+\.\d+\.\d+\.\d+)').search(urllib.URLopener().open('http://jsonip.com/').read()).groupdict()
    return group['ip']

if __name__ == '__main__':
    print get_ip()
