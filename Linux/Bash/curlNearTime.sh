# -L --- follow

curl -L -s -o/dev/null -w'%{http_code}\n%{time_total}\n' https://google.com/|awk 'FNR==2{print $0*1000" ms"};FNR==1{print$0" code"}'
