# manage global ssl options
class certs::ssl_config(
  # https://wiki.mozilla.org/Security/Server_Side_TLS#Recommended_Ciphersuite
  # modifications:
  # * prefer AES256 over AES128
  # * prefer authenticated encryption over CBC
  # * prefer discrete log over elliptic curves. EXCEPT for tls1.0 ciphers
  #   since legacy nss does not support dhparams > 2048 bit
  # * RC4 bias is considered worse than no pfs
  $base_cipher_override = absent,
  $ecdh_curve           = 'secp384r1',
  $dh_parameters_length = 4096,
) {

  $pfs_ae_log    = "DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES256-GCM-SHA384:DHE-DSS-AES128-GCM-SHA256"
  $pfs_ae_ec     = "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256"
  $other_pfs_ae  = "kEDH+AESGCM"
  $pfs_log       = "DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-DSS-AES256-SHA256:DHE-DSS-AES128-SHA256"
  $pfs_ec        = "ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256"
  $other_pfs     = "kEDH+AES"
  $tls10_pfs_ec  = "ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA"
  $tls10_pfs_log = "DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-DSS-AES256-SHA:DHE-DSS-AES128-SHA"
  $legacy_aes    = "AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA"
  $legacy_rc4    = "ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:RC4-SHA"
  $excludes      = "!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS"
  $exclude_proto = "!SSLv2:!SSLv3"

  if ($base_cipher_override) {
    $base_ciphers = $base_cipher_override
  } else {
    $base_ciphers = "${pfs_ae_log}:${pfs_ae_ec}:${other_pfs_ae}:${pfs_log}:${pfs_ec}:${other_pfs}:${tls10_pfs_ec}:${tls10_pfs_log}:${legacy_aes}:${legacy_rc4}"
  }

  $ciphers               = "${base_ciphers}:${excludes}:${exclude_proto}"

  # Opportunistic cipher selection e.g. for smtp s2s communication, where we soft-fail anyways
  $opportunistic_ciphers = "${base_ciphers}:@STRENGTH:!SSLv2"
}
