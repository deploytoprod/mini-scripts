'''
Finds your external IP address
'''

import urllib
import re

def get_ip():
    url = urllib.URLopener()
    resp = url.open('http://myip.dk')
    html = resp.read()
    group=re.compile(u'(?P<ip>\d+\.\d+\.\d+\.\d+)').search(html).groupdict()
    return group['ip']

=======
if __name__ == '__main__':
    print get_ip()
>>>>>>> 7cd49b48087f54d6931f03595821c6aa45d67ecb
