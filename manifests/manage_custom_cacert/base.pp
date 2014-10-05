# basic stuff to manage custom ca's
class certs::manage_custom_cacert::base(
  $purge = true,
) {
  if $::osfamily == 'Debian' {
    $command = 'dpkg-reconfigure ca-certificates'
    $ca_dir = '/usr/share/ca-certificates/extra'
  } elsif $::osfamily == 'RedHat' {
    $command = 'update-ca-trust extract'
    $ca_dir = '/etc/pki/ca-trust/source/anchors'
    if $::operatingsystemmajrelease == 6 {
      exec{'update-ca-trust enable':
        onlyif => 'update-ca-trust check | grep -q DISABLED',
        notify => Exec['update_custom_cas'],
      }
    }
  } else {
    fail("Your osfamily ${::osfamily} is not (yet) supported!")
  }

  file{$ca_dir:
    ensure  => directory,
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  if $purge {
    File[$ca_dir]{
      purge   => true,
      force   => true,
      recurse => true,
      notify  => Exec['update_custom_cas'],
    }
  }

  exec{'update_custom_cas':
    command     => $command,
    refreshonly => true,
  }
}
