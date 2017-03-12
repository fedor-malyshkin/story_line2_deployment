class storyline_infra::jenkins {

	apt::key { 'jenkins-key':
		id => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
		source  => 'https://pkg.jenkins.io/debian/jenkins.io.key',
	} ->
	apt::source { 'jenkins-repo':
  		comment  => 'jenkins repo',
  		location => 'https://pkg.jenkins.io/debian',
		release => '',
  		repos    => 'binary/',
  		include  => {
    		'deb' => true,
  		},
	} ->
	package { 'jenkins':
		ensure => 'installed',
	} ->
	service { 'jenkins':
  		ensure => 'running',
		enable    => true,
	}
}
