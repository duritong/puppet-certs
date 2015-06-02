# basic stuff to manage custom ca's
class certs::manage_custom_cacert::base(
  $purge = true,
) {
  if $::osfamily == 'Debian' {
    $command = 'update-ca-certificates'
    $ca_dir = '/usr/local/share/ca-certificates'
    $dir_group = staff
    $dir_mode = '2775'
  } elsif $::osfamily == 'RedHat' {
    $command = 'update-ca-trust extract'
    $ca_dir = '/etc/pki/ca-trust/source/anchors'
    $dir_group = root
    $dir_mode = '0755'
    if versioncmp($::operatingsystemmajrelease,'7') < 0 {
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
    group   => $dir_group,
    mode    => $dir_mode;
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
