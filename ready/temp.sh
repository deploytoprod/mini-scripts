echo "`sensors |grep temp1 |cut -d ' ' -f 9-9 |sed 's/\+//g'` 53.0" | awk '{if ($1 > $2) system("echo 'Passei\ dos\ 53C' |mail rafael@rafalopes.com.br");}'
