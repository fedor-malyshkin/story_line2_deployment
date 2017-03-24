
node "datahouse01.nlp-project.ru"  {
		include storyline_base::ntp
		include storyline_base::srv_oper
		include storyline_base::ssh
		include storyline_infra::collectd
		include storyline_base::oracle_java
		include storyline_infra::elasticsearch
		include storyline_infra::zookeeper
		include storyline_infra::mongodb

		include storyline_components::crawler
		include storyline_components::server_storm
		include storyline_infra::nginx
		
		include storyline_infra::monit
		include storyline_base::firewall
}
