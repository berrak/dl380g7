##
## This class set up the /root subdirectories and permissions
## including mails (postfix/mutt etc).
##
class hp_root_home::config {

	# set /root directory only for root's eyes
	file { '/root':
		owner => 'root',
		group => 'root',
		mode => '0700',
	}	
	
	# /root files only rw
	exec { 'setrootownership':
		command => "/bin/chmod 0600 /root/*",
		subscribe => File['/root'],
		refreshonly => true,
	}
	
	# create a bin subdirectory directory only for root's binary tools
	file { "/root/bin":
		ensure => "directory",
		owner => 'root',
		group => 'root',
		mode => '0700',
	}
	
	# create a jobs subdirectory directory only for local admins cron scripts
	file { "/root/jobs":
		ensure => "directory",
		owner => 'root',
		group => 'root',
		mode => '0700',
	}	
	
	# set up ~/Maildir mailbox structure for root
	
	file { '/root/Maildir':
		ensure => 'directory',
		 owner => 'root',
		 group => 'root',
		  mode => '0700',
	}
	
    exec { 'make_root_maildirs_new':
		command => '/bin/mkdir -p /root/Maildir/new',
		subscribe => File['/root/Maildir'],
		refreshonly => true,
	}
	
    exec { 'make_root_maildirs_cur':
		command => '/bin/mkdir -p /root/Maildir/cur',
		subscribe => File['/root/Maildir'],
		refreshonly => true,
	}	
	
    exec { 'make_root_maildirs_tmp':
		command => '/bin/mkdir -p /root/Maildir/tmp',
		subscribe => File['/root/Maildir'],
		refreshonly => true,
	}
	
	# ~/Maildir/.Drafts
	
    file { '/root/Maildir/.Drafts':
		 ensure => 'directory',
		  owner => 'root',
		  group => 'root',
		   mode => '0700',
		require => File['/root/Maildir'],
	}
	
    exec { 'make_root_maildirs_drafts_new':
		command => '/bin/mkdir -p /root/Maildir/.Drafts/new',
		subscribe => File['/root/Maildir/.Drafts'],
		refreshonly => true,
	}

    exec { 'make_root_maildirs_drafts_cur':
		command => '/bin/mkdir -p /root/Maildir/.Drafts/cur',
		subscribe => File['/root/Maildir/.Drafts'],
		refreshonly => true,
	}
	
    exec { 'make_root_maildirs_drafts_tmp':
		command => '/bin/mkdir -p /root/Maildir/.Drafts/tmp',
		subscribe => File['/root/Maildir/.Drafts'],
		refreshonly => true,
	}


	# ~/Maildir/.Sent
	
    file { '/root/Maildir/.Sent':
		 ensure => 'directory',
		  owner => 'root',
	 	  group => 'root',
		   mode => '0700',
		require => File['/root/Maildir'],
	}	
	
    exec { 'make_root_maildirs_sent_new':
		command => '/bin/mkdir -p /root/Maildir/.Sent/new',
		subscribe => File['/root/Maildir/.Sent'],
		refreshonly => true,
	}

    exec { 'make_root_maildirs_sent_cur':
		command => '/bin/mkdir -p /root/Maildir/.Sent/cur',
		subscribe => File['/root/Maildir/.Sent'],
		refreshonly => true,
	}
	
    exec { 'make_root_maildirs_sent_tmp':
		command => '/bin/mkdir -p /root/Maildir/.Sent/tmp',
		subscribe => File['/root/Maildir/.Sent'],
		refreshonly => true,
	}

	
}
