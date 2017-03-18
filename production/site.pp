
node "datahouse01.nlp-project.ru"  {
		# include storyline_base::ntp
		# include storyline_base::srv_oper
		# include storyline_base::ssh
		# include storyline_infra::collectd
		# include storyline_base::oracle_java
		# include storyline_infra::elasticsearch
		# include storyline_infra::zookeeper
		# include storyline_infra::mongodb
		# include storyline_infra::monit
		# include storyline_components::crawler

		#include storyline_base::firewall
		resources { 'firewall':
	  		purge => true,
		}

		Firewall {
	  		before  => Class['storyline_base::firewall_post'],
	  		require => Class['storyline_base::firewall_pre'],
		}
 		class { ['storyline_base::firewall_pre', 'storyline_base::firewall_post']: }
		class { 'firewall': }
}
