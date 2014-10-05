# manage an extra CA certificate within your system ca bundle
define certs::manage_custom_cacert(
  $ensure  = present,
  $content = undef,
  $source  = undef,
) {

  if !$content and !$source and $ensure != 'absent' {
    fail("We either need a source or a content for ${name}")
  }

  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease < 6 {
    file_content{
      "ca_cert_${name}":
        ensure => $ensure,
        path   => '/etc/pki/tls/certs/ca-bundle.crt',
    }
    if $source {
      file{"${certs::manage_custom_cacert::legacy_rhel::dir}/${name}":
        source => $source,
      }
      File_content["ca_cert_${name}"]{
        source => "${certs::manage_custom_cacert::legacy_rhel::dir}/${name}"
      }
    } else {
      File_content["ca_cert_${name}"]{
        content => $content,
      }
    }
  } else {
    include certificates::manage_custom_cacert::base
    $file = "${certs::manage_custom_cacert::base::ca_dir}/${name}.crt"
    file{$file:
      notify => Exec['update_custom_cas'],
    }

    if $ensure == 'present' {
      File[$file]{
        owner => root,
        group => 0,
        mode  => '0644',
      }

      if $content {
        File[$file]{
          content => $content,
        }
      } else {
        File[$file]{
          source => $source,
        }
      }
    } else {
      File[$file]{
        ensure => 'absent',
      }
    }
  }
}
