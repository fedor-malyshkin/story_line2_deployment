# Шаги для инициализации

__Все операции проводим под `root`__

1. by SSH generate new keys for me `ssh-keygen -t rsa -b 4096 -C "your_account@example.com"`
1. add public keys to to `/home/ХХХХХ/.ssh/authorized_keys`
1. make initial provisioning
1. Create InfluxDB initial db creation by `curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE storyline"`
1. Create Grafana "view" user
1. Connect Grafana to InfluxDB (see: http://docs.grafana.org/features/datasources/influxdb/)
