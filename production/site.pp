node "default"  { }

node "datahouse01.nlp-project.ru"  {
	include ::limits
	include ::sysctl::base
	include ::logrotate

	include storyline_base::ntp
	include storyline_base::srv_oper
	include storyline_base::ssh
	include storyline_base::java

	include storyline_base::firewall
	include storyline_infra::telegraf

	include storyline_infra::zookeeper
	include storyline_infra::kafka
	include storyline_infra::jmxtrans
	include storyline_infra::hadoop
	include storyline_components::spark
	include storyline_components::server_akka
	include storyline_infra::monit
}

node "datahouse02.nlp-project.ru"  {
	include ::limits
	include ::sysctl::base
	include ::logrotate

	include storyline_base::ntp
	include storyline_base::srv_oper
	include storyline_base::ssh
	include storyline_base::java

	include storyline_base::firewall
	include storyline_infra::telegraf

	include storyline_components::crawler

	include storyline_infra::nginx

	include storyline_infra::zookeeper
	include storyline_infra::kafka
	include storyline_infra::jmxtrans
	include storyline_infra::hadoop
	include storyline_components::spark

	include storyline_infra::monit
}

node "ci.nlp-project.ru"  {
	include ::limits
	include ::sysctl::base
	include ::logrotate

	include storyline_base::ntp
	include storyline_base::srv_oper
	include storyline_base::ssh
	include storyline_base::java

	include storyline_base::firewall
	include storyline_infra::telegraf

	include storyline_infra::influxdb
	include storyline_infra::grafana

	include storyline_infra::elasticsearch

	include storyline_infra::mysql

	include storyline_infra::zookeeper
	include storyline_infra::kafka
	include storyline_infra::jmxtrans
	include storyline_infra::hadoop
	include storyline_components::spark

	include storyline_infra::hive
	include storyline_infra::jenkins

	include storyline_infra::monit
}
