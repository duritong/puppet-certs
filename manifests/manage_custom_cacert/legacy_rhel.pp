# manage requirements for older RHEL systems
class certs::manage_custom_cacert::legacy_rhel {
  $dir = '/var/lib/puppet/manage_CAs'
  file{$dir:
    ensure  => directory,
    owner   => root,
    group   => 0,
    mode    => '0644',
    purge   => true,
    force   => true,
    recurse => true,
  }
}
