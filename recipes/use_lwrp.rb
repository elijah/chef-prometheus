#
# Cookbook Name:: prometheus
# Recipe:: use_lwrp
#
# Author: Robert Berger <rberger@mist.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This recipe does nothing, allows you to `include_recipe "prometheus::use_lwrp"`
# so you can override attributes and use the LWRP[s] in a wrapper cookbook.
# Then `include_recipe "prometheus::default"` to actually install and configure prometheus.

# New workflow:
# - Create wrapper cookbook that
#   - `include_recipe "prometheus::use_lwrp"
#   - Collects any jobs / targets,
#     - Use prometheus_job to create the jobs
#   - Override any needed attributes
#   - `include_recipe "prometheus::default`
