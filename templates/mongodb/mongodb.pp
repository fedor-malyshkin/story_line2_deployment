user { 'mongo':
	ensure => "present",
}

# working dir
file { '/mongodb':
	ensure => "directory",
	recurse => "true",
	owner => "mongo",
	group=> "mongo",
	mode=>"ug=rwx,o=rx",
}

file { '/data':
	ensure => "directory",
	recurse => "true",
	owner => "mongo",
	group=> "mongo",
	mode=>"ug=rwx,o=rx",
}
file { '/data/db':
	ensure => "directory",
	recurse => "true",
	owner => "mongo",
	group=> "mongo",
	mode=>"ug=rwx,o=rx",
}
file { '/data/logs':
	ensure => "directory",
	recurse => "true",
	owner => "mongo",
	group=> "mongo",
	mode=>"ug=rwx,o=rx",
}
