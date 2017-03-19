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
  - grafana: `CREATE USER "grafana" WITH PASSWORD 'grafana'` and `GRANT READ ON "collectd" TO "grafana"` and `GRANT READ ON "storyline" TO "grafana"`
  - crawler: `CREATE USER "crawler" WITH PASSWORD 'crawler'` and `GRANT WRITE ON "storyline" TO "crawler"`


## MongoDB
1. Create admin user:
	```js
	use admin
	db.createUser({ user: "admin", 	pwd: "uqctzewud69!5!I#", roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]})
	```
1. Create additional users:
    - connect as admin: `mongo --port 27017 -u "adminт" -p "uqctzewud69!5!I#" --authenticationDatabase "admin"`
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
