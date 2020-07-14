# options to add to the barbican.conf as secrets (will not be saved in node attribute)
default['openstack']['key-manager']['conf_secrets'] = {}
default['openstack']['key-manager']['conf'].tap do |conf|
  # DEFAULT

  if node['openstack']['key-manager']['syslog']['use']
    conf['DEFAULT']['use_syslog'] = 'true'
    conf['DEFAULT']['log_config_append'] = '/etc/openstack/logging.conf'
  end
  conf['DEFAULT']['syslog_log_facility'] = 'LOG_USER'
  conf['DEFAULT']['use_journal'] = 'false'
  conf['DEFAULT']['syslog_log_facility'] = 'LOG_USER'
  conf['DEFAULT']['log_rotate_interval'] = '1'
  conf['DEFAULT']['log_rotate_interval_type'] = 'days'
  conf['DEFAULT']['log_rotation_type'] = 'interval'
  conf['DEFAULT']['logging_context_format_string'] = '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s'
  conf['DEFAULT']['logging_default_format_string'] = '%(asctime)s.%(msecs)03d %(process)d %(levelname)s %(name)s [-] %(instance)s%(message)s'
  conf['DEFAULT']['logging_debug_format_suffix'] = '%(funcName)s %(pathname)s:%(lineno)d'
  conf['DEFAULT']['logging_exception_prefix'] = '%(asctime)s.%(msecs)03d %(process)d ERROR %(name)s %(instance)s'
  conf['DEFAULT']['logging_user_identity_format'] = '%(user)s %(tenant)s %(domain)s %(user_domain)s %(project_domain)s'
  conf['DEFAULT']['default_log_levels'] = 'amqp'
  conf['DEFAULT']['publish_errors'] = 'false'
  conf['DEFAULT']['instance_format'] = '"[instance: %(uuid)s] "'
  conf['DEFAULT']['instance_uuid_format'] = '"[instance: %(uuid)s] "'
  conf['DEFAULT']['rate_limit_burst'] = '0'
  conf['DEFAULT']['rate_limit_except_level'] = 'CRITICAL'
  conf['DEFAULT']['fatal_deprecations'] = 'false'
  conf['DEFAULT']['rpc_conn_pool_size'] = '30'
  conf['DEFAULT']['conn_pool_min_size'] = '2'
  conf['DEFAULT']['conn_pool_ttl'] = '1200'
  conf['DEFAULT']['executor_thread_pool_size'] = '64'
  conf['DEFAULT']['rpc_response_timeout'] = '60'
  conf['DEFAULT']['control_exchange'] = 'openstack'
  conf['DEFAULT']['run_external_periodic_tasks'] = 'true'
  conf['DEFAULT']['api_paste_config'] = 'api-paste.ini'
  conf['DEFAULT']['wsgi_log_format'] = '%(client_ip)s "%(request_line)s" status: %(status_code)slen: %(body_length)s time: %(wall_seconds).7f'
  conf['DEFAULT']['tcp_keepidle'] = '600'
  conf['DEFAULT']['wsgi_default_pool_size'] = '100'
  conf['DEFAULT']['max_header_line'] = '16384'
  conf['DEFAULT']['wsgi_keep_alive'] = 'true'
  conf['DEFAULT']['admin_role'] = 'admin'
  conf['DEFAULT']['allow_anonymous_access'] = 'false'
  conf['DEFAULT']['max_allowed_request_size_in_bytes'] = '15000'
  conf['DEFAULT']['max_allowed_secret_in_bytes'] = '10000'
  conf['DEFAULT']['sql_idle_timeout'] = '3600'
  conf['DEFAULT']['sql_max_retries'] = '-1'
  conf['DEFAULT']['sql_retry_interval'] = '1'
  conf['DEFAULT']['db_auto_create'] = 'true'
  conf['DEFAULT']['max_limit_paging'] = '100'
  conf['DEFAULT']['default_limit_paging'] = '10'
  conf['DEFAULT']['sql_pool_logging'] = 'false'
  conf['DEFAULT']['sql_pool_size'] = '5'
  conf['DEFAULT']['sql_pool_max_overflow'] = '10'
  conf['DEFAULT']['debug'] = 'false'

  # keystone_authtoken

  conf['keystone_authtoken']['auth_type'] = 'password'
  conf['keystone_authtoken']['region_name'] = node['openstack']['region']
  conf['keystone_authtoken']['username'] = node['openstack']['key-manager']['service_user']
  conf['keystone_authtoken']['project_name'] = node['openstack']['key-manager']['service_role']
  conf['keystone_authtoken']['user_domain_name'] = 'Default'
  conf['keystone_authtoken']['project_domain_name'] = 'Default'

  # certificate

  conf['certificate']['namespace'] = 'barbican.certificate.plugin'
  conf['certificate']['enabled_certificate_plugins'] = 'simple_certificate'

  # certificate_event

  conf['certificate_event']['namespace'] = 'barbican.certificate.event.plugin'
  conf['certificate_event']['enabled_certificate_event_plugins'] = 'simple_certificate_event'

  # cors

  # conf['cors']['allowed_origin'] = ["http://horizon.example.com", "https://horizon.example.com"]
  conf['cors']['allow_credentials'] = 'true'
  conf['cors']['expose_headers'] = 'X-Auth-Token,X-Openstack-Request-Id,X-Project-Id,X-Identity-Status,X-User-Id,X-Storage-Token,X-Domain-Id,X-User-Domain-Id,X-Project-Domain-Id,X-Roles'
  conf['cors']['max_age'] = '3600'
  conf['cors']['allow_methods'] = 'GET,PUT,POST,DELETE,PATCH'
  conf['cors']['allow_headers'] = 'X-Auth-Token,X-Openstack-Request-Id,X-Project-Id,X-Identity-Status,X-User-Id,X-Storage-Token,X-Domain-Id,X-User-Domain-Id,X-Project-Domain-Id,X-Roles'

  # crypto

  conf['crypto']['namespace'] = 'barbican.crypto.plugin'
  conf['crypto']['enabled_crypto_plugins'] = 'simple_crypto'

  # queue

  conf['queue']['enable'] = 'false'

  # simple_crypto_plugin

  # kek = >TODO: define in recipe<
  conf['simple_crypto_plugin']['plugin_name'] = 'Software Only Crypto'

  # snakeoil_ca_plugin

  conf['snakeoil_ca_plugin']['ca_cert_path'] = '<None>'
  conf['snakeoil_ca_plugin']['ca_cert_key_path'] = '<None>'
  conf['snakeoil_ca_plugin']['ca_cert_chain_path'] = '<None>'
  conf['snakeoil_ca_plugin']['ca_cert_pkcs7_path'] = '<None>'
  conf['snakeoil_ca_plugin']['subca_cert_key_directory'] = '/etc/barbican/snakeoil-cas'

  # quotas

  conf['quotas']['quota_secrets'] = '-1'
  conf['quotas']['quota_orders'] = '-1'
  conf['quotas']['quota_containers'] = '-1'
  conf['quotas']['quota_consumers'] = '-1'
  conf['quotas']['quota_cas'] = '-1'

  # retry_scheduler

  conf['retry_scheduler']['initial_delay_seconds'] = '10.0'
  conf['retry_scheduler']['periodic_interval_max_seconds'] = '10.0'

  # secretstore

  conf['secretstore']['namespace'] = 'barbican.secretstore.plugin'
  conf['secretstore']['enabled_secretstore_plugins'] = 'store_crypto' # not safe for production, see https://docs.openstack.org/barbican/queens/install/barbican-backend.html#barbican-backend"
  conf['secretstore']['enable_multiple_secret_stores'] = 'false'

  if node['openstack']['key-manager']['ssl']['enabled']
    conf['ssl']['ca_file'] = node['openstack']['key-manager']['ssl']['chainfile']
    conf['ssl']['cert_file'] = node['openstack']['key-manager']['ssl']['certfile']
    conf['ssl']['key_file'] = node['openstack']['key-manager']['ssl']['keyfile']
    conf['ssl']['version'] = ''
    conf['ssl']['ciphers'] = node['openstack']['key-manager']['ssl']['ciphers']

    # these are aparently ununsed
    # default['openstack']['key-manager']['ssl']['ca_certs_path'] = ''
    # default['openstack']['key-manager']['ssl']['cert_required'] = ''
    # default['openstack']['key-manager']['ssl']['protocol'] = ''
  end
end
