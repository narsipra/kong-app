# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project's packages adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [v0.5.2]

## Updated

- Bump Kong version, 1.4.3 contains [security - fix](https://github.com/Kong/kong/blob/master/CHANGELOG.md#143)

## [v0.5.1]

## Changed

- Remove `registry` from values

## [v0.5.0]

## Changed

- Update the chart to latest [upstream version 1.0.0](https://github.com/Kong/charts) (#043c2c2)

## Updated

- README contains some more information

## [v0.4.6]

## Added

- Bump versions (#31), Fix giantswarm/kong-app/issues/29

## [v0.4.5]

## Added

- Add support for plugins which require multiple configmaps.

## [v0.4.4]

## Removed

- Remove the stale custom plugin configmap.

## [v0.4.3]

## Added

- Add Postgres user and database name as environment variables in the proper templates.

## [v0.4.2]

## Changed

- Change wait container image for kong to init properly DB deployment

## [v0.4.1]

## Changed

- Add registry in all wait images entries to make it deployable in all regions
- Use a fixed busybox version for wait images to make it deterministic

## [v0.4.0]

### Added

- Add support for validation controller as optional.
- Add option to configure a horizontal pod autoscaler.

## [v0.3.0]

### Updated

- Add new version of Kong and Kong ingress controller.
- Add option to deploy redis for rate limiting plugin.
- Add support to configure custom plugins.

## [v0.2.0]

### Updated

- Use retagged images.
- Use ClusterIP for all services except proxy which uses LoadBalancer.
- Add support for an external PostgreSQL database.

## [v0.1.0]

### Added

- Add first version of the kong-app chart based on the community Kong chart.

### Updated

- Enable Kong Ingress Controller mode.
- Use service of type Load Balancer for the Kong proxy service.
- Disable using Postgres and use Kubernetes resources for storing state.
