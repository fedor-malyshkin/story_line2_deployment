class storyline_infra::monit () {

	$template_params_infra = lookup({"name" => "storyline_infra",
        "merge" => {"strategy" => "deep"}})
	$template_params_comp = lookup({"name" => "storyline_components",
	    "merge" => {"strategy" => "deep"}})

	$params = lookup({"name" => "storyline_infra.monit",
	    "merge" => {"strategy" => "deep"}})
	$enabled_startup = $params['enabled_startup']
	$version = $params['version']

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
		content => epp('storyline_infra/monitrc.epp', { 'params_infra' => $template_params_infra,  'params_comp' => $template_params_comp  }),
		notify => Service['monit'],
	}
	if $enabled_startup != true {
		exec { "disable_monit":
			command => "/bin/systemctl disable monit",
			cwd => "/",
		}
	}
	service { 'monit':
		ensure => true,
		enable    => $enabled_startup,
		hasrestart => true,
		hasstatus => true,
	}
}
