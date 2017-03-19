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
