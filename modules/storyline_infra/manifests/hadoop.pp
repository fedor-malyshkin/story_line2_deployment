class storyline_infra::hadoop () {
	$params = lookup({"name" => "storyline_infra.hadoop",
	    "merge" => {"strategy" => "deep"}})

	$version = $params['version']
	$dir_data = $params['dir_data']
	$dir_bin = $params['dir_bin']
	$dir_logs = $params['dir_logs']
	$dir_pids = $params['dir_pids']

	$java_home = $params['java_home']
	# hdfs
	$hdfs_heapsize_mb =  $params['hdfs_heapsize_mb']
	$hdfs_namenode_uri =  $params['hdfs_namenode_uri'] # hdfs://host:port/
	# Path on the local filesystem where the NameNode stores the namespace and transactions logs persistently.
	$hdfs_namenode_data_dir =  $params['hdfs_namenode_data_dir']
	$hdfs_namenode_blocksize_b =  $params['hdfs_namenode_blocksize_b']
	$hdfs_namenode_threads =  $params['hdfs_namenode_threads']
	$hdfs_datanode_data_dir =  $params['hdfs_datanode_data_dir']
	# yarn
	$yarn_heapsize_mb =  $params['yarn_heapsize_mb']
	$yarn_resourcemanager_hostname =  $params['yarn_resourcemanager_hostname']
	$yarn_nodemanager_memory_mb =  $params['yarn_nodemanager_memory_mb']
	$yarn_nodemanager_local_dirs =  $params['yarn_nodemanager_local_dirs']
	$yarn_nodemanager_log_dirs =  $params['yarn_nodemanager_log_dirs']

	$enabled_startup = $params['enabled_startup']
	$enabled_running = $params['enabled_running']

	$certname = $trusted['certname']

	group { 'hadoop':
		ensure => "present",
	} ->
	user { 'hdfs':
		ensure => "present",
		groups => 'hadoop',
		managehome => true,
	}  ->
	user { 'yarn':
		ensure => "present",
		groups => 'hadoop',
		managehome => true,
	}  ->
	exec { "hadoop-mkdir":
		command => "/bin/mkdir -p /data/db && /bin/mkdir -p /data/logs",
		cwd => "/",
		# exec will run unless the command has an exit code of 0
		unless => '/usr/bin/test -d /data/db -a -d /data/logs',
	} ->
	# working dir
	file { [$dir_bin, $dir_logs, $dir_data, $dir_pids] :
		ensure => "directory",
		recurse => "true",
		owner => "hdfs",
		group => "hadoop",
		require => Exec['hadoop-mkdir'],
	} ->
	# hdfs
	file { [$hdfs_namenode_data_dir, $hdfs_datanode_data_dir] :
		ensure => "directory",
		recurse => "true",
		owner => "hdfs",
		group => "hadoop",
		require => Exec['hadoop-mkdir'],
	} ->
	# yarn
	file { [$yarn_nodemanager_local_dirs, $yarn_nodemanager_log_dirs] :
		ensure => "directory",
		recurse => "true",
		owner => "yarn",
		group => "hadoop",
		require => Exec['hadoop-mkdir'],
	} ->
	archive { "hadoop-archive":
		path=> "/provision/hadoop-${version}.tar.gz",
  		source=>"http://apache-mirror.rbc.ru/pub/apache/hadoop/common/hadoop-${version}/hadoop-${version}.tar.gz",
  		extract       => true,
  		extract_path  => "/provision",
  		cleanup       => false,
		notify 		  => Exec['hadoop_move_to_no_version_dir'],
	} ->
	exec { "hadoop_move_to_no_version_dir":
		command => "/bin/mv -f -t ${dir_bin} /provision/hadoop-${version}/* && chown -R hdfs:hadoop ${dir_bin}",
		cwd => "/",
		refreshonly => true,
	} ->
	file { "${dir_bin}/etc/hadoop/core-site.xml":
		replace => true,
		owner => "hdfs",
		group => "hadoop",
		mode=>"ug=rw,o=r",
		content => epp('storyline_infra/hadoop_core.epp'),
		notify => Service['hadoop_namenode', 'hadoop_datanode', 'hadoop_resourcemanager', 'hadoop_nodemanager'],
	} ->
	file { "${dir_bin}/etc/hadoop/hdfs-site.xml":
		replace => true,
		owner => "hdfs",
		group => "hadoop",
		mode=>"ug=rw,o=r",
		content => epp('storyline_infra/hadoop_hdfs.epp'),
		notify => Service['hadoop_namenode', 'hadoop_datanode'],
	} ->
	file { "${dir_bin}/etc/hadoop/yarn-site.xml":
		replace => true,
		owner => "hdfs",
		group => "hadoop",
		mode=>"ug=rw,o=r",
		content => epp('storyline_infra/hadoop_yarn.epp'),
		notify => Service['hadoop_resourcemanager', 'hadoop_nodemanager'],
	}
	['namenode','datanode','resourcemanager', 'nodemanager'].each |String $service| {
		file { "/etc/systemd/system/hadoop_${service}.service":
			replace => true,
			owner => "hdfs",
			group => "hadoop",
			content => epp("storyline_infra/hadoop_${service}_startup.epp"),
			mode=>"ug=rw,o=r",
 		} ->
		file { "${dir_bin}/hadoop_${service}.sh":
			replace => true,
			owner => "hdfs",
			group => "hadoop",
			content => epp("storyline_infra/hadoop_${service}_script.epp"),
			mode=>"ug=rwx,o=r",
		} ->
		service { "hadoop_${service}":
			ensure => $enabled_running,
			enable    => $enabled_startup,
			provider => 'systemd',
			hasrestart => true,
			hasstatus => true,
		}
	}
}
