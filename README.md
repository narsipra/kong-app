[![CircleCI](https://circleci.com/gh/giantswarm/kong-app.svg?style=shield)](https://circleci.com/gh/giantswarm/kong-app)

# kong-app chart

[Kong for Kubernetes](https://github.com/Kong/kubernetes-ingress-controller) is
an open-source Ingress Controller for Kubernetes that offers API management capabilities
with a plugin architecture.

Giant Swarm offers a Kong Managed App which can be installed in tenant clusters.

## Configuration
There are 3 ways that Kong can be configured in Kubernetes:

1. Using a Database (PostgreSQL or Cassandra)
1. Kong Kubernetes Ingress Controller (with CRDs)
1. DBless (no databases and static Configuration file)

The recommended and supported way is to use Ingress Controller (which works
alongside DBless).

This app does not by default provide a database and if a database is required,
then you will need to BYOD (Bring Your Own Database). For testing purposes, it
is possible launch postgres alongside this App (described below).

For detailed configuration options, please refer to the [configuration list](helm/kong-app/README.md#configuration)
also the [`values.yaml` file](helm/kong-app/values.yaml)

Any key value put under the `env` section translates to environment variables
used to control Kong's configuration. Every key is prefixed with KONG_ and
upper-cased before setting the environment variable.

### Kong Ingress Controller (Recommended)
The default installation of the App will use Kong Ingress Controller. This
method uses CRDs to configure various aspects of Kong. Please refer to Kong
Ingress Controller
[documentation](https://github.com/Kong/kubernetes-ingress-controller/tree/master/docs)
for more detailed explanation and usage.

#### Ingress Controller Class
The default ingress controller class used by this app is `kong-app`. This
differs from the upstream default `kong`. We have changed the default, as this
conflicts with other ingress controllers and the default ingress controller in
Giant Swarm clusters is `nginx`.

For more details about this please have a look [upstream deployment
documentation](https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/concepts/deployment.md#multiple-ingress-controllers)

### DBLess Kong
The [official documentation](https://docs.konghq.com/1.4.x/db-less-and-declarative-config/)
explains how DBLess Kong works and the possible limitations. To use this method
of operation with this App, you will need to include the following you your
values YAML:

Using an existing ConfigMap
---------------------------
```YAML
env:
  database: "off"
ingressController:
  enabled: false
dblessConfig:
  configMap: nameOfExistingConfigMap
```

Inline configuration
--------------------
```YAML
env:
  database: "off"
ingressController:
  enabled: false
dblessConfig:
  config:
    _format_version: "1.1"
    services:
      - name: example.com
        url: http://example.com
        routes:
        - name: example
          paths:
          - "/example"
```

### Using your own Database
Kong supports two databases:

- PostgreSQL: 9.5 and above.
- Cassandra: 2.2 and above.

This section will focus on PostgreSQL, however the same process can be equally
applied to Cassandra.

Example database configuration:
```YAML
ingressController:
  enabled: false
env:
  database: "postgress" # can be "off" or "cassandra"
  pg_host: 127.0.0.1
  pg_port: 12345
  pg_user: postgres
  pg_password: # This can also be a string value, but not recommended
    valueFrom:
           secretKeyRef:
              key: kong
              name: postgres
```
You can use any valid database configuration option inside `env`. This is also
how Cassandra can be configured.

_note_: If `pg_port` is not set then it will default to `5432`

#### Installing a database alongside the App
For testing purposes, it is possible to install a PostgreSQL server alongside
the App. To do this:

```YAML
postgresql:
  enabled: true
  postgresqlUsername: kong
  postgresqlDatabase: kong
  service:
    port: 5432
```
(There is no need to add PostgreSQL configuration data to `env`)

Please note: This configuration should only really be used for testing and it
not something we can support

### Using Kong Ingress Controller with a Database
When using Kong Ingress Controller, their shouldn't be a need to use a Database.
However in some cases (for example, plugin support) a data store is
required. In these situations, it is possible to use a mixture of Kong Ingress
Controller and a database.

Like in the case of using a database, Giant Swarm do not support the database and
can only provide best efforts support with this configuration.

To configure, please see ['Using your own Database'](#using-your-own-database).
But ensure that that `ingressController.enabled` is set to `true`.

Note:
> Is it possible to create consumers using the Admin API?
>
> From version 0.5.0 onwards, Kong Ingress Controller tags each entity that it
> manages inside Kong's database and only manages the entities that it creates.
> This means that if consumers and credentials are created dynamically,
> they won't be deleted by the Ingress Controller.
(Taken from https://github.com/Kong/kubernetes-ingress-controller/blob/master/docs/faq.md#is-it-possible-to-create-consumers-using-the-admin-api)

### Kong Ingress Controller CRDs
If you wish to use the Kong Ingress Controller and use Helm 2, please be aware
that by default the CRDs will not be installed. If you wish to add them at
install time, please set the following:

  - In values file
    ```
    ingressController:
      installCRDs: true
    ```
  - On command line
    ```
    --set ingressController.installCRDs=true
    ```

This is not required for Helm 3, as CRDs will be installed automatically.

## Known Issues

## Credit

* https://github.com/Kong/charts/

## Security Policy

### Reporting a Vulnerability

Please visit https://www.giantswarm.io/responsible-disclosure for information on
reporting security issues.
