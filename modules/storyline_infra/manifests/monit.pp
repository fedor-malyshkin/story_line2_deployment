class storyline_infra::monit () {

	$template_params = lookup({"name" => "storyline_infra",
        "merge" => {"strategy" => "deep"}})

	$params = lookup({"name" => "storyline_infra.monit",
	    "merge" => {"strategy" => "deep"}})
	$enabled_startup = $params['enabled_startup']
	$version = $params['version']
	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	file { '/etc/monitrc':
		ensure => 'absent',
	}
	package { 'monit':
		ensure => $version,
	} ->
	file { '/etc/monit/monitrc':
		ensure => 'file',
		replace => true,
		# https://docs.puppet.com/puppet/4.9/lang_template_epp.html#parameters
		content => epp('storyline_infra/monitrc.epp', { 'params' => $template_params }),
		notify => Service['monit'],
	}
	service { 'monit':
		ensure => $service_status,
		enable    => true,
		hasrestart => true,
		hasstatus => true,
	}
}
