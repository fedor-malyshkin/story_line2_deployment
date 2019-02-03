# Безопасность

Некоторые вопросы безопасности выполняются вручную (в связи с тем, что настройка в автоматическом режим достаточно проблематична).

## InfluxDB

1. Create admin user:
  - comment out options "auth-enabled" in [http] section
  - restart influxdb
  - create "admin" user by `CREATE USER "admin" WITH PASSWORD 'mprdig0jw91@89M#' WITH ALL PRIVILEGES`
  - enable options "auth-enabled" in [http] section
  - restart influxdb
1. Create additional users:
  - connect as admin: `influx -username admin -password mprdig0jw91@89M#`
  - grafana:
    - `CREATE USER "grafana" WITH PASSWORD 'grafana'`
	- `GRANT READ ON "telegraf" TO "grafana"`
	- `GRANT READ ON "storyline" TO "grafana"` (**and other bases**)
  - telegraf:
    - `CREATE USER "telegraf" WITH PASSWORD 'telegraf'`
	- `GRANT WRITE ON "telegraf" TO "telegraf"`  
  - crawler:
    - `CREATE USER "crawler" WITH PASSWORD 'crawler'`
	- `GRANT WRITE ON "crawler" TO "crawler"`
  - server_web:
    - `CREATE USER "server_web" WITH PASSWORD 'server_web'`
	- `GRANT WRITE ON "storyline" TO "server_web"`
  - jmxtrans:
    - `CREATE USER "jmxtrans" WITH PASSWORD 'jmxtrans'`
	- `GRANT WRITE ON "storyline" TO "server_storm"`  
  - finnaly:
	- CREATE DATABASE telegraf WITH DURATION 4w
	- CREATE DATABASE storyline WITH DURATION 4w
	- CREATE DATABASE crawler WITH DURATION 4w
	- CREATE DATABASE server_web WITH DURATION 4w
	- CREATE DATABASE kafka WITH DURATION 4w
	- CREATE USER "grafana" WITH PASSWORD 'grafana'
	- GRANT READ ON "telegraf" TO "grafana"
	- GRANT READ ON "storyline" TO "grafana"
	- GRANT READ ON "crawler" TO "grafana"
	- GRANT READ ON "server_web" TO "grafana"
	- GRANT READ ON "kafka" TO "grafana"
	- CREATE USER "telegraf" WITH PASSWORD 'telegraf'
	- GRANT WRITE ON "telegraf" TO "telegraf"
	- CREATE USER "crawler" WITH PASSWORD 'crawler'
	- GRANT WRITE ON "crawler" TO "crawler"
	- CREATE USER "server_web" WITH PASSWORD 'server_web'
	- GRANT WRITE ON "server_web" TO "server_web"
	- CREATE USER "jmxtrans" WITH PASSWORD 'jmxtrans'
	- GRANT ALL ON "kafka" TO "jmxtrans"

## MongoDB
1. Create admin user:
	```js
	use admin
	db.createUser({ user: "admin", 	pwd: "uqctzewud69!5!I#", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]})
	db.grantRolesToUser(    "admin", [ { role: "dbAdminAnyDatabase", db: "admin" } ] )
	db.grantRolesToUser(    "admin", [ { role: "clusterAdmin", db: "admin" } ] )
	```
1. Create additional users:
    - connect as admin: `mongo --port 27017 -u "admin" -p "uqctzewud69!5!I#" --authenticationDatabase "admin"`
    - crawler:
	```js
	use crawler
	db.createUser({user: "crawler", pwd: "crawler", roles: [ { role: "readWrite", db: "crawler" }]})
	```
