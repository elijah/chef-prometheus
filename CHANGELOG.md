# Change Log
All notable changes to this project will be documented in this file.

## [Unreleased][unreleased]

## [0.5.1] - 2015-03-25
### Changed
- Updated documentation.

## [0.5.0] - 2015-03-25
### Added
- Added systemd init for redhat platform family version 7 or greater.
- Default init style per platform.
- Install Prometheus via pre-compiled binary.
- Added the prometheus_job resource for defining Prometheus scraping jobs.
- Attribute flag to externally manage prometheus.conf file.

### Changed
- Removed flags that were deprecated in the prometheus 0.12.0 release.

### Contributors for this release:

- [Eric Richardson](https://github.com/ewr) - External jobs config and prometheus job resource.

Thank You!

## [0.4.0] - 2015-03-12
### Fixed
- Fix init template path bug on chef 11.x.

## [0.3.0] - 2015-03-11
### Fixed
- Fixed cookbook badge in README

## [0.2.0] - 2015-03-11
### Fixed
- License defined in metadata.

## 0.1.0 - 2015-03-11
### Changed
- Initial release of prometheus cookbook

[unreleased]: https://github.com/rayrod2030/chef-prometheus/compare/0.5.1...HEAD
[0.5.1]: https://github.com/rayrod2030/chef-prometheus/compare/0.5.0...0.5.1
[0.5.0]: https://github.com/rayrod2030/chef-prometheus/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/rayrod2030/chef-prometheus/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/rayrod2030/chef-prometheus/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/rayrod2030/chef-prometheus/compare/0.1.0...0.2.0
