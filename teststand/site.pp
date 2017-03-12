node default {
	include storyline_base::ntp
	include storyline_base::srv_oper
	include storyline_base::ssh
	include storyline_infra::jenkins
	include storyline_base::oracle_java
	include storyline_infra::collectd
	include storyline_infra::influxdb
	include storyline_infra::grafana


	/*
	resources { 'firewall':
	  purge => true,
	}

	class { 'firewall': }
	*/


}
