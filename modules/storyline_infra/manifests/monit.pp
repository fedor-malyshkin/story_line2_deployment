class storyline_infra::monit (
	Boolean $enabled_startup = false
	) {

	$template_params =lookup({"name" => "storyline_infra", 
        "merge" => {"strategy" => "deep"}})

	$service_status = $enabled_startup ? {
	  true  => 'running',
	  false => 'stopped',
	}

	file { '/etc/monitrc':
		ensure => 'absent',
	}
	package { 'monit':
		ensure => 'present',
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
