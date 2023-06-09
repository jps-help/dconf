# @summary Create dconf profiles
#
# @example Creating dconf profiles
#   dconf::profile { 'example_profile':
#     entries => {
#       'user' => {
#         'type'  => 'user',
#         'order' => 10,
#        },
#       'local' => {
#         'type'  => 'system',
#         'order' => 21,
#       },
#       'site' => {
#         'type'  => 'system',
#         'order' => 21,
#       },
#     },
#   }
#
# @param profile_dir Absolute path to dconf profile directory
#
# @param profile_file Absolute path to dconf profile file
#
# @param profile_dir_mode File permissions for dconf profile directory
#
# @param profile_file_mode File permissions for dconf profile file
#
# @param purge Control whether to purge the dconf profile directory of unmanaged files
#
# @param ensure Whether to ensure presence or absence of the dconf profile
#
# @param default_entry_order Default order of profile entries
#
# @param entries List of entries to include in the dconf profile
define dconf::profile (
  Stdlib::Absolutepath $profile_dir = '/etc/dconf/profile',
  Stdlib::Absolutepath $profile_file = "${profile_dir}/${name}",
  String $profile_dir_mode = '0755',
  String $profile_file_mode = '0644',
  Boolean $purge = false,
  Enum['present','absent'] $ensure = 'present',
  String $default_entry_order = '25',
  Optional[Hash] $entries = undef,
) {
  ensure_resource('file',$profile_dir, { ensure  => 'directory', mode    => $profile_dir_mode, purge   => $purge, recurse => $purge, })
  if $ensure == 'present' {
    concat { "profile_${name}":
      path  => $profile_file,
      mode  => $profile_file_mode,
      order => 'numeric',
    }
    $entries.each |String[1] $db_name, Hash $attrs| {
      concat::fragment { "profile_${name}_${db_name}":
        target  => $profile_file,
        content => "${attrs['type']}-db:${db_name}\n",
        order   => get($attrs,'order',$default_entry_order),
        require => Concat["profile_${name}"],
      }
    }
  } elsif $ensure == 'absent' {
    file { $profile_file:
      ensure => 'absent',
    }
  } else {
    warning("Unknown resource state for dconf profile.\nReceived: ${ensure}\nExpected: 'present' OR 'absent'")
  }
}
