# Wrapping libraries

When starting out with Jsonnet, it is very likely that you'll with existing code and
dependencies. Developing on these can seem confusing and tedious, however there are
several techniques that can help us iterate at different velocities.


## Objectives

- Wrap and extend a dependency locally
- Developing on upstream libraries

## Lesson

### Wrapping libraries

As shown in the [refactoring exercise](lesson3.md#solution), let's initialize a new
project with `k8s-libsonnet`:

`$ jb init`

`$ jb install github.com/jsonnet-libs/k8s-libsonnet/1.23@main`

`$ mkdir lib`

`$ echo "(import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet')" > lib/k.libsonnet`

And install
[`privatebin-libsonnet`](https://github.com/Duologic/privatebin-libsonnet):

`$ jb install github.com/Duologic/privatebin-libsonnet`

~~~jsonnet
local privatebin = import 'github.com/Duologic/privatebin-libsonnet/main.libsonnet';

{
  privatebin: privatebin.new(),
}

// example1/example1.jsonnet
~~~


This is relatively simple web application that exposes itself on port `8080`.

---

~~~jsonnet
local k = import 'ksonnet-util/kausal.libsonnet';

{
  new(
    name='privatebin',
    image='privatebin/nginx-fpm-alpine:1.3.5',
  ):: {

    local container = k.core.v1.container,
    container::
      container.new('privatebin', image)
      + container.withPorts([
        k.core.v1.containerPort.newNamed(name='http', containerPort=8080),
      ])
      + k.util.resourcesRequests('50m', '100Mi')
      + k.util.resourcesLimits('150m', '300Mi')
      + container.livenessProbe.httpGet.withPath('/')
      + container.livenessProbe.httpGet.withPort('http')
      + container.readinessProbe.httpGet.withPath('/')
      + container.readinessProbe.httpGet.withPort('http')
    ,

    local deployment = k.apps.v1.deployment,
    deployment: deployment.new(name, 1, [self.container]),

    service: k.util.serviceFor(self.deployment),
  },
}

// example1/vendor/github.com/Duologic/privatebin-libsonnet/main.libsonnet
~~~


`privatebin-libsonnet` is relatively simple, it already exposes the `container` separate
from the `deployment` and we can pick the `name` and `image` when initializing it with
`new()`.

One hurdle: the library does not expose a function to change the port. We could go about
and create a change request upstream, but considering this is a very trivial change it
might not be worth the time.

So, let's try to deal with it locally.

> **`ksonnet-util`**
>
> The [`ksonnet-util`](https://github.com/grafana/jsonnet-libs/tree/master/ksonnet-util)
> library contains a set of util functions developed around the now deprecated
> [`ksonnet-lib`](https://github.com/ksonnet/ksonnet-lib). It also functions as
> a compatibility layer towards `k8s-libsonnet`. Many of the util functions have since
> made it into `k8s-libsonnet` with the aim to make this library obsolete over time.

---

For the purpose of this exercise we want to run this application for different teams and
each team should be able to change the port to their liking.


Create a local library in `lib/privatebin/`:

~~~jsonnet
local privatebin = import 'github.com/Duologic/privatebin-libsonnet/main.libsonnet';
local k = import 'k.libsonnet';

privatebin
{
  withPort(port): {
    container+:
      k.core.v1.container.withPorts([
        k.core.v1.containerPort.newNamed(
          name='http',
          containerPort=port
        ),
      ]),
  },
}

// example1/lib/privatebin/main.libsonnet
~~~


Here we import the vendored library and extend it. We are extending the privatebin
library here extended with the `withPort()` function that will change the ports of the
`container`.

Have a look at the
[`container`](https://jsonnet-libs.github.io/k8s-libsonnet/1.18/core/v1/container/#fn-withports)
and
[`containerPort`](https://jsonnet-libs.github.io/k8s-libsonnet/1.18/core/v1/containerPort/#fn-newnamed)
documentation for the details on each.

---

~~~jsonnet
local privatebin = import 'privatebin/main.libsonnet';

{
  privatebin:
    privatebin.new('backend')
    + privatebin.withPort(9000),
}

// example1/example2.jsonnet
~~~


To use the new library, we need to change the import to match `privatebin/main.libsonnet`,
`JSONNET_PATH` will expand it to `lib/privatebin/main.libsonnet`.

This makes the `withPort()` function available and now teams can set their own port.

In this example, the backend team has named its privatebin `backend`, this will generate
a deployment/service with that name. As the name is quite generic, this may cause
conflicts.

---

Let's add a suffix to prevent the naming conflict:

~~~jsonnet
local privatebin = import 'github.com/Duologic/privatebin-libsonnet/main.libsonnet';
local k = import 'k.libsonnet';

privatebin
{
  new(team):
    super.new(team + '-privatebin'),

  withPort(port): {
    container+:
      k.core.v1.container.withPorts([
        k.core.v1.containerPort.newNamed(
          name='http',
          containerPort=port
        ),
      ]),
  },
}

// example2/lib/privatebin/main.libsonnet
~~~


Here we call `super.new()`, this means it will use the `new()` function defined in
privatebin.

The deployment/service will now be suffixed with `-privatebin`, ie. `backend-privatebin`.

#### Use case: replace Pentagon with External Secrets Operator

Wrapping libraries is a powerful concept, it can be used to manipulate or even replace
whole systems that are used across a code base.

~~~jsonnet
local pentagon = import 'github.com/grafana/jsonnet-libs/pentagon/pentagon.libsonnet';

pentagon
{
  _config+:: {
    local this = self,
    pentagon+: {
      vault_address:
        if this.cluster_name == 'dev'
        then 'vault-dev.example.com'
        else 'vault-prod.example.com',
    },
  },
}

// usecase-pentagon/lib/pentagon/example1.libsonnet
~~~


~~~jsonnet
local pentagon = import 'pentagon/example1.libsonnet';

{
  pentagon: pentagon {
    _config+:: {
      cluster_name: 'dev',
      namespace: 'app1',
    },
    pentagon_mappings: [
      pentagon.pentagonKVMapping('path/to/secret', 'k8sSecretName'),
    ],
  },
}

// usecase-pentagon/example1.jsonnet
~~~


For synchronizing secrets between Vault and Kubernetes, Grafana Labs used a fork of
[Pentagon](https://github.com/grafana/pentagon). This process was a deployment per
namespace with each team managing their own deployments. To facilitate a consistent
connection configuration we wrapped the [pentagon
library](https://github.com/grafana/jsonnet-libs/tree/master/pentagon). Teams could create
a Vault->Kubernetes mapping with the shortcut function `pentagonKVmapping` to populate the
`pentagon_mappings` array (which gets turned into a configMap).

As a deployment per namespace accumulated quite a bit of resources, we opted to replace it
with [External Secrets Operator](https://external-secrets.io/). This means we'd go from
many deployments and configMaps (at least one of each per namespace) to a single operator
deployment per cluster, a secretStore per namespace and many externalSecret objects.

---

~~~jsonnet
local externalSecrets = import 'external-secrets-libsonnet/main.libsonnet';
local pentagon = import 'github.com/grafana/jsonnet-libs/pentagon/pentagon.libsonnet';

pentagon
{
  local this = self,

  // Remove/hide resources
  _config+:: {},
  deployment:: {},
  config_map:: {},
  rbac:: {},
  cluster_role:: {},
  cluster_role_binding:: {},

  local externalSecret = externalSecrets.nogroup.v1beta1.externalSecret,
  externalSecrets: std.sort([
    local mapping = this.pentagon_mappings_map[m];

    externalSecret.new(mapping.secretName)
    + externalSecret.spec.secretStoreRef.withName('vault-backend')
    + externalSecret.spec.secretStoreRef.withKind('SecretStore')
    + externalSecret.spec.target.withName(mapping.secretName)
    + externalSecret.spec.withDataFrom([
      {
        extract: {
          key: mapping.vaultPath,
        },
      },
    ])

    for m in std.objectFields(this.pentagon_mappings_map)
  ], function(e) if std.objectHasAll(e, 'idx') then e.idx else 0),
}

// usecase-pentagon/lib/pentagon/example2.libsonnet
~~~


The operator deployment and secretStore objects are managed centrally, only thing left to
do is replace the secret mappings everywhere. With more than 2500 mappings, this would
have been a hell of a refactoring job. Fortunately we had the wrapped library in place and
we could transform the mappings array into externalSecret objects transparently.

As the wrapped library is aware of the cluster it was being deployed too, we were able
gradually roll this out across the fleet.

Finally with this in place, we informed each team on how to refactor their code to use
External Secrets directly, allowing them to work on it at their own pace.

### Developing on vendored libraries

As it gives immediate feedback, it often happens that a vendored library is developed
alongside the project that is using it. However any invocation of `jb install` will remove
changes from `vendor/`, which makes it a little bit more challenging. Let's have a look at
the different options.

#### Simply edit files in `vendor/`

This is the easiest except the risk of loosing changes is highest. For testing small
changes this is probably safe, it gives immediate feedback whether the changes match
expectations. The small changes should be pushed upstream early on so they don't get lost.

#### Clone dependency in `vendor/`

Similar but a bit more elaborate, it is possible to `git clone` the dependency straight
into `vendor/`. It faces the same risk as above but allows for a shorter loop to push
changes upstream.

#### Use local reference

`$ jb install ../../lesson3/example2/lib/webserver`

~~~json
{
  "version": 1,
  "dependencies": [
    {
      "source": {
        "local": {
          "directory": "../../lesson3/example2/lib/webserver"
        }
      },
      "version": ""
    }
  ],
  "legacyImports": true
}

// example3/jsonnetfile.json
~~~


```
.
├── jsonnetfile.json
├── jsonnetfile.lock.json
└── vendor
    └── webserver -> ../../../lesson3/example2/lib/webserver
```

This installs a local library relative to the project root with a symlink. Changes made in
`vendor/` or on the real location are unaffected by `jb install` however it changes
`jsonnetfile.json` to something that can't be shared.

#### Symlink in `lib/`

`$ ln -s ../../../lesson3/example2/lib/webserver lib/`

```
.
└── lib
    └── webserver -> ../../../lesson3/example2/lib/webserver
```

By relying on the import order, a symlink in `lib/` could be made. With `lib/` being
matched before `vendor/`, it will be used first. This approach is unaffected by `jb
install` and doesn't change `jsonnetfile.json`.


## Conclusion

Wrapping libraries locally by leveraging the extensible nature of Jsonnet can be very
useful. It can alter default behavior that is more suitable for the project.

Developing directly on vendored libraries on the other hand is quite clumsy, the
techniques described require a bit of pragmatism to be useful. jsonnet-bundler could
benefit from a feature to make this easier.


