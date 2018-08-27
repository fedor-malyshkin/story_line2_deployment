node "elasticsearch"  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_infra::elasticsearch
	include storyline_infra::monit
}

node "zookeeper"  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_infra::zookeeper
	include storyline_infra::monit
}

node "mongodb"  {
	include storyline_base::ntp
	include storyline_infra::mongodb
	include storyline_infra::monit
}

node "crawler"  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_components::crawler
	include storyline_infra::monit
}

node "server_web"  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_components::server_web
	include storyline_infra::nginx
	include storyline_infra::monit
}

node "spark"  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_components::spark
	include storyline_infra::monit
}

node "kafka"  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_infra::kafka
	include storyline_infra::monit
}


node default  {
	include storyline_base::ntp
	include storyline_base::java
	include storyline_components::server_web
	include storyline_infra::nginx
}
