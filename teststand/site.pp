node default {
	include storyline_base::ntp
	include storyline_base::srv_oper
	include storyline_base::ssh
	include storyline_infra::jenkins
	include storyline_base::java
	include storyline_infra::influxdb
	include storyline_infra::grafana
	include storyline_infra::monit

	include storyline_base::firewall
}
