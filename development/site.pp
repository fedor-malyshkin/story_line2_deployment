node "elasticsearch"  {
	include storyline_base::ntp
	include storyline_base::oracle_java
	include storyline_infra::monit
	include storyline_infra::elasticsearch
}

node "zookeeper"  {
	include storyline_base::ntp
	include storyline_base::oracle_java
	include storyline_infra::monit
	include storyline_infra::zookeeper
}

node "24ce9fc3b826"  {
	include storyline_base::ntp
	include storyline_base::oracle_java
	include storyline_infra::monit
	include storyline_infra::zookeeper
	include storyline_infra::elasticsearch
}
