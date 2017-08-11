#
# Cookbook Name:: prometheus
# Attributes:: default
#

# Directory where the prometheus binary will be installed
default['prometheus']['dir']                                                              = '/opt/prometheus'

# Location of Prometheus binary
default['prometheus']['binary']                                                           = "#{node['prometheus']['dir']}/prometheus"

# Location of Prometheus pid file
default['prometheus']['pid']                                                              = '/var/run/prometheus.pid'

# Install method.  Currently supports source and binary.
default['prometheus']['install_method']                                                   = 'binary'

# Init style.
# rubocop:disable Style/ConditionalAssignment
case node['platform_family']
when 'debian'
  if node['platform'] == 'ubuntu' && node['platform_version'].to_f < 15.04
    default['prometheus']['init_style'] = 'upstart'
  elsif node['platform'] == 'debian' && node['platform_version'].to_f < 8.0
    default['prometheus']['init_style'] = 'runit'
  else
    default['prometheus']['init_style'] = 'systemd'
  end
when 'rhel', 'fedora'
  if node['platform_version'].to_i >= 7
    default['prometheus']['init_style']                                                   = 'systemd'
  else
    default['prometheus']['init_style']                                                   = 'init'
  end
else
  default['prometheus']['init_style']                                                     = 'init'
end
# rubocop:enable Style/ConditionalAssignment

# Location for Prometheus logs
default['prometheus']['log_dir']                                                          = '/var/log/prometheus'

# Prometheus version to build
default['prometheus']['version']                                                          = '1.6.3'

# Prometheus source repository.
default['prometheus']['source']['git_repository']                                         = 'https://github.com/prometheus/prometheus.git'

# Prometheus source repository git reference.  Defaults to version tag.  Can
# also be set to a branch or master.
default['prometheus']['source']['git_revision']                                           = "v#{node['prometheus']['version']}"

# System user to use
default['prometheus']['user']                                                             = 'prometheus'

# System group to use
default['prometheus']['group']                                                            = 'prometheus'

# Set if you want ot use the root user
default['prometheus']['use_existing_user']                                                = false

# Location for Prometheus pre-compiled binary.
# Default for testing purposes
default['prometheus']['binary_url']                                                       = "https://github.com/prometheus/prometheus/releases/download/v#{node['prometheus']['version']}/prometheus-#{node['prometheus']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
# Default for testing purposes
default['prometheus']['checksum']                                                         = 'bb4e3bf4c9cd2b30fc922e48ab584845739ed4aa50dea717ac76a56951e31b98'

# If file extension of your binary can not be determined by the URL
# then define it here. Example 'tar.bz2'
default['prometheus']['file_extension']                                                   = ''

# Should we allow external config changes?
default['prometheus']['allow_external_config']                                            = false

# Prometheus job configuration chef template name.
default['prometheus']['job_config_template_name']                                         = 'prometheus.yml.erb'

# Prometheus custom configuration cookbook.  Use this if you'd like to bypass the
# default prometheus cookbook job configuration template and implement your own
# templates and recipes to configure Prometheus jobs.
default['prometheus']['job_config_cookbook_name']                                         = 'prometheus'

# FLAGS Section: Any attributes defined under the flags hash will be used to
# generate the command line flags for the Prometheus executable.

# Prometheus configuration file name.

default['prometheus']['flags']['config.file']                                             = "#{node['prometheus']['dir']}/prometheus.yml"

# Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal, panic].
default['prometheus']['flags']['log.level']                                               = 'info'

# Alert manager HTTP API timeout.
timeout_flag = Gem::Version.new(node['prometheus']['version']) <= Gem::Version.new('0.16.2') ? 'http-deadline' : 'timeout'
default['prometheus']['flags']["alertmanager.#{timeout_flag}"]                            = '10s'

# The capacity of the queue for pending alert manager notifications.
default['prometheus']['flags']['alertmanager.notification-queue-capacity']                = 100

# The URL of the alert manager to send notifications to.
default['prometheus']['flags']['alertmanager.url']                                        = 'http://127.0.0.1/alert-manager/'

# Maximum number of queries executed concurrently.
default['prometheus']['flags']['query.max-concurrency']                                   = 20

# Staleness delta allowance during expression evaluations.
default['prometheus']['flags']['query.staleness-delta']                                   = '5m0s'

# Maximum time a query may take before being aborted.
default['prometheus']['flags']['query.timeout']                                           = '2m0s'

# If approx. that many time series are in a state that would require a recovery
# operation after a crash, a checkpoint is triggered, even if the checkpoint interval
# hasn't passed yet. A recovery operation requires a disk seek. The default limit
# intends to keep the recovery time below 1min even on spinning disks. With SSD,
# recovery is much faster, so you might want to increase this value in that case
# to avoid overly frequent checkpoints.
default['prometheus']['flags']['storage.local.checkpoint-dirty-series-limit']             = 5000

# The period at which the in-memory index of time series is checkpointed.
default['prometheus']['flags']['storage.local.checkpoint-interval']                       = '5m0s'

# If set, the local storage layer will perform crash recovery even if the last
# shutdown appears to be clean.
default['prometheus']['flags']['storage.local.dirty']                                     = false

# The size in bytes for the fingerprint to metric index cache.
default['prometheus']['flags']['storage.local.index-cache-size.fingerprint-to-metric']    = 10485760

# The size in bytes for the metric time range index cache.
default['prometheus']['flags']['storage.local.index-cache-size.fingerprint-to-timerange'] = 5242880

# The size in bytes for the label name to label values index cache.
default['prometheus']['flags']['storage.local.index-cache-size.label-name-to-label-values']  = 10485760

# The size in bytes for the label pair to fingerprints index cache.
default['prometheus']['flags']['storage.local.index-cache-size.label-pair-to-fingerprints']  = 20971520

# How many chunks to keep in memory. While the size of a chunk is 1kiB, the total
# memory usage will be significantly higher than this value * 1kiB. Furthermore,
# for various reasons, more chunks might have to be kept in memory temporarily.
default['prometheus']['flags']['storage.local.memory-chunks']                             = 1048576

# Base path for metrics storage.
default['prometheus']['flags']['storage.local.path']                                      = '/var/lib/prometheus'

# If set, a crash recovery will perform checks on each series file. This might take a very long time.
default['prometheus']['flags']['storage.local.pedantic-checks']                           = false

# How long to retain samples in the local storage.
default['prometheus']['flags']['storage.local.retention']                                 = '360h0m0s'

# When to sync series files after modification. Possible values:
# 'never', 'always', 'adaptive'. Sync'ing slows down storage performance
# but reduces the risk of data loss in case of an OS crash. With the
# 'adaptive' strategy, series files are sync'd for as long as the storage
# is not too much behind on chunk persistence.
default['prometheus']['flags']['storage.local.series-sync-strategy']                      = 'adaptive'

# The URL of the remote InfluxDB server to send samples to. None, if empty.
default['prometheus']['flags']['storage.remote.influxdb-url']                             = ''

# The name of the database to use for storing samples in InfluxDB.
default['prometheus']['flags']['storage.remote.influxdb.database']                        = 'prometheus'

# The InfluxDB retention policy to use.
default['prometheus']['flags']['storage.remote.influxdb.retention-policy']                = 'default'

# The URL of the OpenTSDB instance to send samples to. None, if empty.
default['prometheus']['flags']['storage.remote.opentsdb-url']                             = ''

# The timeout to use when sending samples to the remote storage.
default['prometheus']['flags']['storage.remote.timeout']                                  = '30s'

# Path to the console library directory.
default['prometheus']['flags']['web.console.libraries']                                   = 'console_libraries'

# Path to the console template directory, available at /console.
default['prometheus']['flags']['web.console.templates']                                   = 'consoles'

# Enable remote service shutdown.
default['prometheus']['flags']['web.enable-remote-shutdown']                              = false

# The URL under which Prometheus is externally reachable (for
# example, if Prometheus is served via a reverse proxy). Used for
# generating relative and absolute links back to Prometheus itself. If
# omitted, relevant URL components will be derived automatically.
default['prometheus']['flags']['web.external-url']                                        = ''

# Address to listen on for the web interface, API, and telemetry.
default['prometheus']['flags']['web.listen-address']                                      = ':9090'

# Path under which to expose metrics.
default['prometheus']['flags']['web.telemetry-path']                                      = '/metrics'

# Read assets/templates from file instead of binary.
# web.use-local-assets flag got removed in 0.17
# https://github.com/prometheus/prometheus/commit/a542cc86096e1bad694e04d307301a807583dfc6
if Gem::Version.new(node['prometheus']['version']) <= Gem::Version.new('0.16.2')
  default['prometheus']['flags']['web.use-local-assets']                                  = false
end

# Path to static asset directory, available at /user.
default['prometheus']['flags']['web.user-assets']                                         = ''

# Alertmanager attributes

# Install method. Currently supports source and binary.
default['prometheus']['alertmanager']['install_method']                                   = 'source'

# Location of Alertmanager binary
default['prometheus']['alertmanager']['binary']                                           = "#{node['prometheus']['dir']}/alertmanager"

# Alertmanager version to build
default['prometheus']['alertmanager']['version']                                          = '0.6.2'

# Alertmanager source repository.
default['prometheus']['alertmanager']['git_repository']                                   = 'https://github.com/prometheus/alertmanager.git'

# Alertmanager source repository git reference.  Defaults to version tag.  Can
# also be set to a branch or master.
default['prometheus']['alertmanager']['git_revision']                                     = node['prometheus']['alertmanager']['version']

# Location for Alertmanager pre-compiled binary.
# Default for testing purposes
default['prometheus']['alertmanager']['binary_url']                                       = 'https://github.com/prometheus/alertmanager/releases/download/v0.6.2/alertmanager-0.6.2.linux-amd64.tar.gz'

# Checksum for pre-compiled binary
# Default for testing purposes
default['prometheus']['alertmanager']['checksum']                                         = '8b796592b974a1aa51cac4e087071794989ecc957d4e90025d437b4f7cad214a'

# If file extension of your binary can not be determined by the URL
# then define it here. Example 'tar.bz2'
default['prometheus']['alertmanager']['file_extension']                                   = ''

# Alertmanager configuration file name.
default['prometheus']['alertmanager']['config.file']                                      = "#{node['prometheus']['dir']}/alertmanager.conf"

# Alertmanager configuration storage directory
default['prometheus']['alertmanager']['storage.path']                                     = "#{node['prometheus']['dir']}/data"

# Alertmanager configuration chef template name.
default['prometheus']['alertmanager']['config_cookbook_name']                             = 'prometheus'

# Alertmanager custom configuration cookbook.  Use this if you'd like to bypass the
# default prometheus cookbook Alertmanager configuration template and implement your own
# templates and recipes to configure Alertmanager.
default['prometheus']['alertmanager']['config_template_name']                             = 'alertmanager.conf.erb'

# Array of alert rules filenames to be inserted in prometheus.yml.erb under "rule_files"
default['prometheus']['rule_filenames']                                                   = nil

default['prometheus']['alertmanager']['notification'] = {}
