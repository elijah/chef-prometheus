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
default['prometheus']['install_method']                                                   = 'source'

# Init style.
case node['platform_family']
when 'debian'
  default['prometheus']['init_style']                                                     = 'runit'
when 'rhel', 'fedora'
  if node['platform_version'].to_i >= 7
    default['prometheus']['init_style']                                                   = 'systemd'
  else
    default['prometheus']['init_style']                                                   = 'init'
  end
else
  default['prometheus']['init_style']                                                     = 'init'
end

# Location for Prometheus logs
default['prometheus']['log_dir']                                                          = '/var/log/prometheus'

# Prometheus version to build
default['prometheus']['version']                                                          = '0.12.0'

# Prometheus source repository.
default['prometheus']['source']['git_repository']                                         = 'https://github.com/prometheus/prometheus.git'

# Prometheus source repository git reference.  Defaults to version tag.  Can
# also be set to a branch or master.
default['prometheus']['source']['git_revision']                                           = node['prometheus']['source']['version']

# System user to use
default['prometheus']['user']                                                             = 'prometheus'

# System group to use
default['prometheus']['group']                                                            = 'prometheus'

# Set if you want ot use the root user
default['prometheus']['use_existing_user']                                                = false

# Location for Prometheus pre-compiled binary.
# Default for testing purposes
default['prometheus']['binary_url']                                                       = 'https://sourceforge.net/projects/prometheusbinary/files/prometheus-ubuntu14.tar.bz2/'

# Checksum for pre-compiled binary
# Default for testing purposes
default['prometheus']['checksum']                                                         = '10b24708b97847ba8bdd41f385f492a8edd460ec3c584c5b406a6c0329cc3a4e'

# If file extension of your binary can not be determined by the URL
# then define it here. Example 'tar.bz2'
default['prometheus']['file_extension']                                                   = ''

# Should we allow external config changes?
default['prometheus']['allow_external_config']                                            = false

# Prometheus job configuration chef template name.
default['prometheus']['job_config_template_name']                                         = 'prometheus.conf.erb'

# Prometheus custom configuration cookbook.  Use this if you'd like to bypass the
# default prometheus cookbook job configuration template and implement your own
# templates and recipes to configure Prometheus jobs.
default['prometheus']['job_config_cookbook_name']                                         = 'prometheus'

# FLAGS Section: Any attributes defined under the flags hash will be used to
# generate the command line flags for the Prometheus executable.

# Alert manager HTTP API timeout.
default['prometheus']['flags']['alertmanager.http-deadline']                              = '10s'

# The capacity of the queue for pending alert manager notifications.
default['prometheus']['flags']['alertmanager.notification-queue-capacity']                = '100'

# The URL of the alert manager to send notifications to.
default['prometheus']['flags']['alertmanager.url']                                        = ''

# log to standard error as well as files
default['prometheus']['flags']['alsologtostderr']                                         = false

# Prometheus configuration file name.
default['prometheus']['flags']['config.file']                                             = "#{node['prometheus']['dir']}/prometheus.conf"

# when logging hits line file:N, emit a stack trace
default['prometheus']['flags']['log_backtrace_at']                                        = ''

# If non-empty, write log files in this directory
default['prometheus']['flags']['log_dir']                                                 = ''

# log to standard error instead of files
default['prometheus']['flags']['logtostderr']                                             = false

# Staleness delta allowance during expression evaluations.
default['prometheus']['flags']['query.staleness-delta']                                   = '5m0s'

# Maximum time a query may take before being aborted.
default['prometheus']['flags']['query.timeout']                                           = '2m0s'

# logs at or above this threshold go to stderr
default['prometheus']['flags']['stderrthreshold']                                         = 0

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
default['prometheus']['flags']['storage.local.path']                                      = '/tmp/metrics'

# How long to retain samples in the local storage.
default['prometheus']['flags']['storage.local.retention']                                 = '360h0m0s'

# The timeout to use when sending samples to OpenTSDB.
default['prometheus']['flags']['storage.remote.timeout']                                  = '30s'

# The URL of the OpenTSDB instance to send samples to.
default['prometheus']['flags']['storage.remote.url']                                      = ''

# log level for V logs
default['prometheus']['flags']['v']                                                       = 0

# comma-separated list of pattern=N settings for file-filtered logging
default['prometheus']['flags']['vmodule']                                                 = ''

# Path to the console library directory.
default['prometheus']['flags']['web.console.libraries']                                   = 'console_libraries'

# Path to the console template directory, available at /console.
default['prometheus']['flags']['web.console.templates']                                   = 'consoles'

# Enable remote service shutdown.
default['prometheus']['flags']['web.enable-remote-shutdown']                              = false

# Address to listen on for the web interface, API, and telemetry.
default['prometheus']['flags']['web.listen-address']                                      = ':9090'

# Path under which to expose metrics.
default['prometheus']['flags']['web.telemetry-path']                                      = '/metrics'

# Read assets/templates from file instead of binary.
default['prometheus']['flags']['web.use-local-assets']                                    = false

# Path to static asset directory, available at /user.
default['prometheus']['flags']['web.user-assets']                                         = ''
