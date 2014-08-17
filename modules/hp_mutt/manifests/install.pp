##
## 'Define' to install mutt resource file.
##
##  Sample use:
##  	hp_mutt::install { 'root': mailserver_hostname => 'rohan' }
##      hp_mutt::install { 'bekr': mailserver_hostname => 'rohan' }
##
define hp_mutt::install ( $mailserver_hostname='' ) {

    # ensures package mutt is installed (class executed only one time)
    include hp_mutt

    if $mailserver_hostname == '' {
        fail("FAIL: The mailserver hostname parameter is missing.")
    }
    
    # facter

    $mydomain = $::domain

    # mutt configuration for direct access on the mail server
    # and else for normal user remote access from our lan hosts with imap.
    # User root will only read local maildir mailbox (debug local mails)

    if ( $::hostname == $mailserver_hostname ) or ( $name == 'root' ) {
        $mailspool = $::hp_mutt::params::localmailspool
        $mailfolder = $::hp_mutt::params::localmailfolder
        
        $imap_user = $::hp_mutt::params::no_imap_user
        $imap_passwd = $::hp_mutt::params::no_imap_passwd
        
        
    } else {
        $mailspool = "imap://${mailserver_hostname}/INBOX"
        $mailfolder = "imap://${mailserver_hostname}.${mydomain}"
                
        $imap_user = "set imap_user = $name"
        $imap_passwd = "set imap_pass = $::hp_mutt::params::mytestpasswd"
    
    }
    

    # do not create Maildir for root (already by module 'root_home')
    
    if $name == 'root' {
    
        # directory for mutt configurations etc
    
        file { "/root/.mutt":
            ensure => "directory",
              owner => $name,
              group => $name,
              mode => '0700',
        }  
    
        file { "/root/.mutt/muttrc" : 
            content =>  template( 'hp_mutt/muttrc.erb' ),
              owner => 'root',
              group => 'root',
            require => File["/root/.mutt"],
        }
    
    } else {

        # Do not 'require' user home directory and do not create
        # with Puppet. Create the user first with the usual
        # cli tools like 'adduser' and then re-run P't.
        
        # Below actions should fail (not because of the missing
        # directory) but because Puppet knows missing a user id.

        # directory for mutt configurations etc

        file { "/home/${name}/.mutt":
             ensure => "directory",
              owner => $name,
              group => $name,
               mode => '0750',
        }  

        file { "/home/${name}/.mutt/muttrc" : 
            content =>  template( 'hp_mutt/muttrc.erb' ),
              owner => $name,
              group => $name,
            require => File["/home/${name}/.mutt"],
              
        }
        
        # set up ~/Maildir mailbox structure for each user. Set owner-
        # ship to user, for 'tmp','cur', 'new' created with 'exec'
        
        file { "/home/${name}/Maildir":
             ensure => "directory",
              owner => $name,
              group => $name,
               mode => '0750',
        }
        
        exec { "make_${name}_maildirs_new":
            command => "/bin/mkdir -p /home/${name}/Maildir/new && /bin/chown ${name}:${name} /home/${name}/Maildir/new",
            subscribe => File["/home/${name}/Maildir"],
            refreshonly => true,
        }
        
        exec { "make_${name}_maildirs_cur":
            command => "/bin/mkdir -p /home/${name}/Maildir/cur && /bin/chown ${name}:${name} /home/${name}/Maildir/cur",
            subscribe => File["/home/${name}/Maildir"],
            refreshonly => true,
        }	
        
        exec { "make_${name}_maildirs_tmp":
            command => "/bin/mkdir -p /home/${name}/Maildir/tmp && /bin/chown ${name}:${name} /home/${name}/Maildir/tmp",
            subscribe => File["/home/${name}/Maildir"],
            refreshonly => true,
        }
        
        # ~/Maildir/.Drafts
        
        file { "/home/${name}/Maildir/.Drafts":
             ensure => "directory",
              owner => $name,
              group => $name,
               mode => '0750',
            require => File["/home/${name}/Maildir"],
        }
        
        exec { "make_${name}_maildirs_drafts_new":
            command => "/bin/mkdir -p /home/${name}/Maildir/.Drafts/new && /bin/chown ${name}:${name} /home/${name}/Maildir/.Drafts/new",
            subscribe => File["/home/${name}/Maildir/.Drafts"],
            refreshonly => true,
        }
    
        exec { "make_${name}_maildirs_drafts_cur":
            command => "/bin/mkdir -p /home/${name}/Maildir/.Drafts/cur && /bin/chown ${name}:${name} /home/${name}/Maildir/.Drafts/cur",
            subscribe => File["/home/${name}/Maildir/.Drafts"],
            refreshonly => true,
        }
        
        exec { "make_${name}_maildirs_drafts_tmp":
            command => "/bin/mkdir -p /home/${name}/Maildir/.Drafts/tmp && /bin/chown ${name}:${name} /home/${name}/Maildir/.Drafts/tmp",
            subscribe => File["/home/${name}/Maildir/.Drafts"],
            refreshonly => true,
        }
    
    
        # ~/Maildir/.Sent
        
        file { "/home/${name}/Maildir/.Sent":
             ensure => "directory",
              owner => $name,
              group => $name,
               mode => '0750',
            require => File["/home/${name}/Maildir"],
        }	
        
        exec { "make_${name}_maildirs_sent_new":
            command => "/bin/mkdir -p /home/${name}/Maildir/.Sent/new && /bin/chown ${name}:${name} /home/${name}/Maildir/.Sent/new",
            subscribe => File["/home/${name}/Maildir/.Sent"],
            refreshonly => true,
        }
    
        exec { "make_${name}_maildirs_sent_cur":
            command => "/bin/mkdir -p /home/${name}/Maildir/.Sent/cur && /bin/chown ${name}:${name} /home/${name}/Maildir/.Sent/cur",
            subscribe => File["/home/${name}/Maildir/.Sent"],
            refreshonly => true,
        }
        
        exec { "make_${name}_maildirs_sent_tmp":
            command => "/bin/mkdir -p /home/${name}/Maildir/.Sent/tmp && /bin/chown ${name}:${name} /home/${name}/Maildir/.Sent/tmp",
            subscribe => File["/home/${name}/Maildir/.Sent"],
            refreshonly => true,
        }     
        
        
    }
    
}