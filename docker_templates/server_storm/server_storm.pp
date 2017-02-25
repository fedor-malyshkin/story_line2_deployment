# working dir
file { '/server_storm':
	ensure => "directory",
	recurse => "true",
	mode=>"ug=rwx,o=rx",
}

file { '/data':
	ensure => "directory",
	recurse => "true",
	mode=>"ug=rwx,o=rx",
}
file { '/data/db':
	ensure => "directory",
	recurse => "true",
	mode=>"ug=rwx,o=rx",
}
file { '/data/logs':
	ensure => "directory",
	recurse => "true",
	mode=>"ug=rwx,o=rx",
}
