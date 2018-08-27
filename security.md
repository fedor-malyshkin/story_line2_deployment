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
  - grafana: `CREATE USER "grafana" WITH PASSWORD 'grafana'` and `GRANT READ ON "telegraf" TO "grafana"` and `GRANT READ ON "storyline" TO "grafana"` (**and other bases**)
- crawler: `CREATE USER "telegraf" WITH PASSWORD 'telegraf'` and `GRANT WRITE ON "telegraf" TO "telegraf"`  
  - crawler: `CREATE USER "crawler" WITH PASSWORD 'crawler'` and `GRANT WRITE ON "crawler" TO "crawler"`
  - server_web: `CREATE USER "server_web" WITH PASSWORD 'server_web'` and `GRANT WRITE ON "storyline" TO "server_web"`
  - server_storm: `CREATE USER "server_storm" WITH PASSWORD 'server_storm'` and `GRANT WRITE ON "storyline" TO "server_storm"`
  - finnaly:
	- CREATE DATABASE telegraf WITH DURATION 4w
	- CREATE DATABASE storyline WITH DURATION 4w
	- CREATE DATABASE crawler WITH DURATION 4w
	- CREATE DATABASE server_web WITH DURATION 4w
	- CREATE DATABASE server_storm WITH DURATION 4w
	- CREATE USER "grafana" WITH PASSWORD 'grafana'
	- GRANT READ ON "telegraf" TO "grafana"
	- GRANT READ ON "storyline" TO "grafana"
	- GRANT READ ON "crawler" TO "grafana"
	- GRANT READ ON "server_web" TO "grafana"
	- GRANT READ ON "server_storm" TO "grafana"
	- CREATE USER "telegraf" WITH PASSWORD 'telegraf'
	- GRANT WRITE ON "telegraf" TO "telegraf"
	- CREATE USER "crawler" WITH PASSWORD 'crawler'
	- GRANT WRITE ON "crawler" TO "crawler"
	- CREATE USER "server_web" WITH PASSWORD 'server_web'
	- GRANT WRITE ON "server_web" TO "server_web"
	- CREATE USER "server_storm" WITH PASSWORD 'server_storm'
	- GRANT WRITE ON "server_storm" TO "server_storm"




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
    - collectd:
	```js
	use admin
	db.createUser({user: "collectd", pwd: "collectd", roles: [ { role: "readAnyDatabase", db: "admin" }, { role: "clusterMonitor", db: "admin" } ]});
	```
	- server_storm:
	```js
	use storyline
	db.createUser({user: "server_storm", pwd: "server_storm", roles: [ { role: "readWrite", db: "crawler" }, { role: "readWrite", db: "storyline" } ]});
	```
