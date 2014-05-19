# generate a dhparams file
define certs::dhparams(){
  include certs::ssl_config
  exec{"generate_dh_params_${name}":
    command => "openssl dhparam -out ${name} ${certs::ssl_config::dh_parameters_length}",
    creates => $name,
    timeout => '-1'
  } -> file{$name:
    ensure  => present,
    owner   => root,
    group   => 0,
    mode    => '0644';
  }
  if str2bool($::selinux) {
    File[$name]{
      seltype => 'cert_t',
    }
  }
}
