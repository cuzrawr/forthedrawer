#
# little guide.
#

rebuild image with:

	docker-compose build --no-cache

run with:

	docker-compose up


 ----
 dockerized gemini server, https://git.sr.ht/~yotam/shavit
 alpine image slightly hardened ( ssh docker access are broken )
 multiuser setup done with Caddy filemanager. - improve this
 
 localhost:8080                       - filemanager
 localhost:1965 ( or just localhost ) - gemini server  

 ----
 Multiuser guide: 
 1) Go to filemanager web face and register new user <username>
 2) Create "index.gmi" write something, then save it.
 3) Now this "index.gmi" file served by gemini.
 You can access it with any gemini client:
                 gemini://localhost/<username>

 ---- 
 Admin username / pass is  " admin / admin ".

 ----

 !                                         !                                   !
 ! Keep in mind this project are only working example, not for production use. !
 !                                         !                                   !
