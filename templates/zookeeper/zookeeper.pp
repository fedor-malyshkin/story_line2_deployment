user { 'zoo':
	ensure => "present",
}

# working dir
file { '/zookeeper':
	ensure => "directory",
	recurse => "true",
	owner => "zoo",
	group=> "zoo",
	mode=>"ug=rwx,o=rx",
}

file { '/data':
	ensure => "directory",
	recurse => "true",
	owner => "zoo",
	group=> "zoo",
	mode=>"ug=rwx,o=rx",
}
file { '/data/db':
	ensure => "directory",
	recurse => "true",
	owner => "zoo",
	group=> "zoo",
	mode=>"ug=rwx,o=rx",
}
file { '/data/logs':
	ensure => "directory",
	recurse => "true",
	owner => "zoo",
	group=> "zoo",
	mode=>"ug=rwx,o=rx",
}
