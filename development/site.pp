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

node "mongodb"  {
	include storyline_base::ntp
	include storyline_infra::mongodb
	include storyline_infra::monit
}

node "crawler"  {
	include storyline_base::ntp
	include storyline_base::oracle_java
	include storyline_components::crawler
	include storyline_infra::monit
}

node "24ce9fc3b826"  {
	include storyline_base::ntp
	include storyline_components::crawler
	include storyline_infra::monit
}
