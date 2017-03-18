
node "datahouse01.nlp-project.ru"  {
		include storyline_base::ntp
		include storyline_base::srv_oper
		include storyline_base::ssh
		include storyline_infra::collectd
		include storyline_base::oracle_java
		include storyline_infra::elasticsearch
		include storyline_infra::zookeeper
		include storyline_infra::mongodb
		include storyline_infra::monit
		include storyline_components::crawler

		# purge unmanaged rules
		resources { 'firewall':
		  purge => true,
		}
		# add 'firewall' class with my pre/post
		include storyline_base::firewall
}
