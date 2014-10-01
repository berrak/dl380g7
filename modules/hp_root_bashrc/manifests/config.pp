##
## This class customize root's .bashrc
##
class hp_root_bashrc::config {

    $ostype = $::lsbdistid	
	
	if $ostype == 'Debian' {
	 
		file { '/root/.bashrc':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_deb',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		}
	
		# This file contains all customization for root
		file { '/root/.bashrc_root':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_root_deb',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
			require => File['/root/.bashrc'],
		}
		
		# if .bash_root changes, source it
		exec { 'deb_source_changes_due_to_changes_in_bashrc_root':
			command => '/bin/bash . /root/.bashrc_root',
			subscribe => File['/root/.bashrc_root'],
			refreshonly => true,
		}	
	
	} elsif $ostype == 'OracleServer' {
	
		file { '/root/.bash_profile':
			source => 'puppet:///modules/hp_root_bashrc/bash_profile_rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		}
	
		file { '/root/.bashrc':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		   require => File['/root/.bash_profile'],
		}
	
		# This file contains all customization for root
		file { '/root/.bashrc_root':
			source => 'puppet:///modules/hp_root_bashrc/bashrc_root_rpm',
			 owner => 'root',
			 group => 'root',
			  mode => '0600',
		   require => File['/root/.bash_profile'],
		}
	
		# if .bashrc changes, source it
		exec { 'rpm_source_changes_due_to_changes_in_bashrc':
			command => '/bin/bash . /root/.bashrc',
			subscribe => File['/root/.bashrc'],
			refreshonly => true,
		}
		
		# if .bash_root changes, source it
		exec { 'rpm_source_changes_due_to_changes_in_bashrc_root':
			command => '/bin/bash . /root/.bash_root',
			subscribe => File['/root/.bashrc_root'],
			refreshonly => true,
		}		
	
	} else {
		fail("FAIL: Unknown $ostype distribution. Aborting...")
	}	

}
