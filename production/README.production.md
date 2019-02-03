# Шаги для инициализации

__Все операции проводим под `root`__

1. by SSH generate new keys for me `ssh-keygen -t rsa -b 4096 -C "your_account@example.com"`
1. add public keys to to `/home/ХХХХХ/.ssh/authorized_keys`
1. Create InfluxDB initial db creation by `curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE storyline WITH DURATION 4w"` (**and other bases**)
1. Apply security settings like enable authentication, adding users and so on...
1. Create Grafana "view" user
1. Connect Grafana to InfluxDB (see: http://docs.grafana.org/features/datasources/influxdb/)
1. Create swap-file (http://mydebianblog.blogspot.ru/2010/05/swap-swap-linux.html)
	1. dd if=/dev/zero of=/swapfile bs=1M count=5000
	1. mkswap /swapfile
	1. swapon /swapfile
	1. echo "/swapfile none swap sw 0 0" >> /etc/fstab
1. make HDFS formatting
1. import schema in mysql'DB for Hive, restart Hive services
