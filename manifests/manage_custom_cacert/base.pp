# basic stuff to manage custom ca's
class certificates::manage_custom_cacert::base(
  $purge = true,
) {
  if $::osfamily == 'Debian' {
    $command = 'dpkg-reconfigure ca-certificates'
    $ca_dir = '/usr/share/ca-certificates/extra'
  } elsif $::osfamily == 'RedHat' {
    $command = 'update-ca-trust extract'
    $ca_dir = '/etc/pki/ca-trust/source/anchors'
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
    File[$directory]{
      purge   => true,
      force   => true,
      recurse => true,
      notify  => Exec['update_custom_cas'],
    }
  }

  exec{'update_custom_cas':
    command     => $command
    refreshonly => true,
  }
}
