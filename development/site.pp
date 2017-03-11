node "elasticsearch"  {
	include storyline_base::ntp
	include storyline_base::oracle_java
	include storyline_infra::elasticsearch
	include storyline_infra::monit
}

node "zookeeper"  {
	include storyline_base::ntp
	include storyline_base::oracle_java
	include storyline_infra::zookeeper
	include storyline_infra::monit
}

node "24ce9fc3b826"  {
	include storyline_base::ntp
	include storyline_infra::collectd
	include storyline_infra::influxdb
	include storyline_infra::grafana
	include storyline_infra::monit
}
