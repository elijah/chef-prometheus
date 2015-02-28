prometheus Cookbook
=====================

This cookbook installs the [Prometheus][] monitoring system and time-series database.

Requirements
------------
- Chef 11 or higher
- Ruby 1.9.3 or higher

Platform
--------
Tested on

* Ubuntu 14.04

Attributes
----------
In order to keep the README managable and in sync with the attributes, this
cookbook documents attributes inline. The usage instructions and default
values for attributes can be found in the individual attribute files.

Recipes
-------

### default
The default recipe installs [Prometheus][] using the default `install_method` and
supervises the [Prometheus][] binary under [runit][].

Dependencies
------------

The following cookbooks are dependencies:

* [build-essential][]
* [apt][]
* [runit][]


## Usage

### prometheus::default

Include `prometheus` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[prometheus::default]"
  ]
}
```

Development
-----------
Please see the [Contributing](CONTRIBUTING.md) and [Issue Reporting](ISSUES.md) Guidelines.

License & Authors
------

- Author: Ray Rodriguez <rayrod2030@gmail.com>

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
