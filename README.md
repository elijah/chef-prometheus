prometheus Cookbook
=====================
[![Cookbook](http://img.shields.io/cookbook/v/prometheus.svg)](https://github.com/rayrod2030/chef-prometheus)
[![Build Status](https://travis-ci.org/rayrod2030/chef-prometheus.svg?branch=master)](https://travis-ci.org/rayrod2030/chef-prometheus?branch=master)
[![Gitter chat](https://img.shields.io/badge/Gitter-rayrod2030%2Fchef--prometheus-brightgreen.svg)](https://gitter.im/rayrod2030/chef-prometheus)

This cookbook installs the [Prometheus][] monitoring system and time-series database.

Requirements
------------
- Chef 12 or higher
- Ruby 2.2 or higher

Platform
--------
Tested on

* Ubuntu 14.04
* Ubuntu 12.04
* Debian 7.7
* Centos 6.6
* Centos 7.0

Attributes
----------
In order to keep the README managable and in sync with the attributes, this
cookbook documents attributes inline. The usage instructions and default
values for attributes can be found in the individual attribute files.

Recipes
-------

### default
The `default` recipe installs creates all the default [Prometheus][] directories,
config files and and users.  Default also calls the configured `install_method`
recipe and finally calls the prometheus `service` recipe.

### source
The `source` recipe builds Prometheus from a Github source tag.

### binary
The `binary` recipe retrieves and installs a pre-compiled Prometheus build from
a user-defined location.

### service
The `service` recipe configures Prometheus to run under a process supervisor.
Default supervisors are chosen based on distribution. Currently supported
supervisors are init, runit, systemd, upstart and bluepill.

Resource/Provider
-----------------

### prometheus_job

This resource adds a job definition to the Prometheus config file.  Here is an
example of using this resource to define the default Prometheus job:

```ruby
prometheus_job 'prometheus' do
  scrape_interval   '15s'
  target            "http://localhost#{node['prometheus']['flags']['web.listen-address']}#{node['prometheus']['flags']['web.telemetry-path']}"
end
```

Note: This cookbook uses the accumulator pattern so you can define multiple
prometheus_job’s and they will all be added to the Prometheus config.

Externally managing `prometheus.conf`
-------------------------------------

If you prefer to manage your `prometheus.conf` file externally using your own
inventory or service discovery mechanism you can set
`default['prometheus']['allow_external_config']` to `true`.

Dependencies
------------

The following cookbooks are dependencies:

* [build-essential][]
* [apt][]
* [yum][]
* [runit][]
* [bluepill][]
* [accumulator][]
* [ark][]


## Usage

### prometheus::default

Include `prometheus` in your node's `run_list` to execute the standard deployment of prometheus:

```json
{
  "run_list": [
    "recipe[prometheus::default]"
  ]
}
```

### prometheus::use_lwrp

Used to load promethus cookbook from wrapper cookbook.

`prometheus::use_lwrp` doesn't do anything other than allow you to include the
Prometheus cookbook into your wrapper or app cookbooks. Doing this allows you to
override prometheus attributes and use the prometheus LWRP (`prometheus_job`) in
your wrapper cookbooks.

```ruby
# Load the promethues cookbook into your wrapper so you have access to the LWRP and attributes

include_recipe "prometheus::use_lwrp"

# Add a rule filename under `rule_files` in prometheus.yml.erb
node.set['prometheus']['rule_filenames'] = ["#{node['prometheus']['dir']}/alert.rules"]

# Example of using search to populate prometheus.yaml jobs using the prometheus_job LWRP
# Finds all the instances that are in the current environment and are taged with "node_exporter"
# Assumes that the service instances were tagged in their own recipes.
client_servers = search(:node, "environment:#{node.chef_environment} AND tags:node_exporter")

# Assumes service_name is an attribute of each node
client_servers.each do |server|
	prometheus_job server.service_name do
  	  scrape_interval   ‘15s’
	  target            “#{server.fqdn}#{node[‘prometheus’][‘flags’][‘web.listen-address’]}"
	  metrics_path       "#{node[‘prometheus’][‘flags’][‘web.telemetry-path’]}”
	end
end

# Now run the default recipe that does all the work configuring and deploying prometheus
include_recipe "prometheus::default"
```

Development
-----------
Please see the [Contributing](CONTRIBUTING.md) and [Issue Reporting](ISSUES.md) Guidelines.

License & Authors
------

- Author: Ray Rodriguez <rayrod2030@gmail.com>
- Author: kristian järvenpää <kristian.jarvenpaa@gmail.com>

```text
Licensed under the Apache License, Version 2.0 (the “License”);
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[build-essential]: https://github.com/opscode-cookbooks/build-essential
[apt]: https://github.com/opscode-cookbooks/apt
[runit]: https://github.com/hw-cookbooks/runit
[Prometheus]: https://github.com/prometheus/prometheus
[bluepill]: https://github.com/opscode-cookbooks/bluepill
[ark]: https://github.com/burtlo/ark
[yum]: https://github.com/chef-cookbooks/yum
[accumulator]: https://github.com/kisoku/chef-accumulator
