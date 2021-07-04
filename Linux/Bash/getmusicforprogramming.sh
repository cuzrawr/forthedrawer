#
# getmusicforprogramming.sh - get my favorite music. With progress bar!!!
#

wget --no-config --no-check-certificate --random-wait --accept "*.mp3" -nd -c $(wget --no-config --no-check-certificate --random-wait -q -O - "https://musicforprogramming.net/rss.php" | grep -Eo "http.+mp3" | sort -u )
