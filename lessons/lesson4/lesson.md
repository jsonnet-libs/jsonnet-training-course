### Wrapping libraries

As shown in the [refactoring exercise](lesson3.md#solution), let's initialize a new project with
`k8s-libsonnet`:

`$ jb init`

`$ jb install github.com/jsonnet-libs/k8s-libsonnet/1.23@main`

`$ mkdir lib`

`$ echo "(import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet')" > lib/k.libsonnet`

And install
[`privatebin-libsonnet`](https://github.com/Duologic/privatebin-libsonnet):

`$ jb install github.com/Duologic/privatebin-libsonnet`

%(example1/example1.jsonnet)s

This is relatively simple web application that exposes itself on port `8080`.

For the purpose of this exercise we want to run this application for different teams and
each team should be able to change the port to their liking.

---

%(example1/vendor/github.com/Duologic/privatebin-libsonnet/main.libsonnet)s

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

Create a local library in `lib/privatebin/`:

%(example1/lib/privatebin/main.libsonnet)s

Here we import the vendored library and extend it. Read `privatebin { ... }` as `privatebin + { ... }`.

We are extending the privatebin library here extended with the `withPort()` function that
will change the ports of the `container`.

Have a look at the
[`container`](https://jsonnet-libs.github.io/k8s-libsonnet/1.18/core/v1/container/#fn-withports)
and
[`containerPort`](https://jsonnet-libs.github.io/k8s-libsonnet/1.18/core/v1/containerPort/#fn-newnamed)
documentation for the details on each.

---

%(example1/example2.jsonnet)s

To use the new library, we need to change the import to match `privatebin/main.libsonnet`,
`JSONNET_PATH` will expand it to `lib/privatebin/main.libsonnet`.

This makes the `withPort()` function available and now teams can set their own port.

In this example, the backend team has named its privatebin `backend`, this will generate
a deployment/service with that name. As the name is quite generic, this may cause for
conflicts.

---

Let's add a suffix to prevent the naming conflict:

%(example1/lib/privatebin/main.libsonnet)s

Here we call `super.new()`, this means it will use the `new()` function defined in
privatebin.

The deployment/service will now be suffixed with `-privatebin`, ie. `backend-privatebin`.

#### Use case: replace [Pentagon](https://github.com/grafana/pentagon) with [External Secrets Operator](https://external-secrets.io/)

Wrapping libraries is a powerful concept, it can be used to manipulate or even replace
whole systems that are used across a code base.

%(usecase-pentagon/lib/pentagon/example1.libsonnet)s

%(usecase-pentagon/example1.jsonnet)s

For synchronizing secrets between Vault and Kubernetes, Grafana Labs used Pentagon. This
process was a deployment per namespace with each team managing their own deployments. To
facilitate a consistent connection configuration we wrapped the [pentagon
library](https://github.com/grafana/jsonnet-libs/tree/master/pentagon). Teams could create
a Vault->Kubernetes mapping with the shortcut function `pentagonKVmapping` to populate the
`pentagon_mappings` array (which gets turned into a configMap).

As a deployment per namespace accumulated quite a bit of resources, we opted to replace it
with [External Secrets Operator](https://external-secrets.io/). This means we'd go from
many deployments and configMaps (at least one of each per namespace) to a single operator
deployment per cluster, a secretStore per namespace and many externalSecret objects.

---

%(usecase-pentagon/lib/pentagon/example2.libsonnet)s

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

> Idea: jsonnet-bundler could benefit from a feature to make this easier.


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

%(example3/jsonnetfile.json)s

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

By relying on the import order, a symlink in `lib/` could be made. With `lib/` being matched before `vendor/`, it will be used first. This approach is unaffected by `jb install` and doesn't change `jsonnetfile.json`.
