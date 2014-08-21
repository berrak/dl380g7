##
## Configuration of chkrootkit
##
class hp_chkrootkit::config {

    # use a dummy place holder file for configuration and
    # and move the real configurations (options) to a cron script

    file { "/etc/chkrootkit.conf":
         source => "puppet:///modules/hp_chkrootkit/chkrootkit.conf",
          owner => 'root',
          group => 'root',
        require => Package["chkrootkit"],
    }
    
    # local admin new start script to /root/jobs
    
    file { "/root/jobs/cron.runchkrootkit":
         source => "puppet:///modules/hp_chkrootkit/cron.runchkrootkit",
          owner => 'root',
          group => 'root',
           mode => '0700',
        require => Package["chkrootkit"],
    }
    
    # create a local admin scheduled cron job in cron.d
    
    file { '/etc/cron.d/chkrootkit' :
         source =>  "puppet:///modules/hp_chkrootkit/chkrootkit",
          owner => 'root',
          group => 'root',
           mode => '0644',
		require => Package["chkrootkit"],           
    }
    
    
	# This is NON-executable file that prevents maintainer changes
	# or run-parts to execute a daily cron job (is now run in cron.d)
	
    file { '/etc/cron.daily/chkrootkit' :
         source =>  "puppet:///modules/hp_chkrootkit/chkrootkit.dummy",
          owner => 'root',
          group => 'root',
           mode => '0644',
		require => Package["chkrootkit"],           
    }
    

}