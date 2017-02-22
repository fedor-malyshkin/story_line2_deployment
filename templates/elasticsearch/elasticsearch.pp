user { 'elastic':
	ensure => "present",
}

# working dir
file { '/elasticsearch':
	ensure => "directory",
	recurse => "true",
	owner => "elastic",
	group=> "elastic",
	mode=>"ug=rwx,o=rx",
}

file { '/data':
	ensure => "directory",
	recurse => "true",
	owner => "elastic",
	group=> "elastic",
	mode=>"ug=rwx,o=rx",
}
file { '/data/db':
	ensure => "directory",
	recurse => "true",
	owner => "elastic",
	group=> "elastic",
	mode=>"ug=rwx,o=rx",
}
file { '/data/logs':
	ensure => "directory",
	recurse => "true",
	owner => "elastic",
	group=> "elastic",
	mode=>"ug=rwx,o=rx",
}
