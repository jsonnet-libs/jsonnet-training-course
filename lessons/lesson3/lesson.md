In [Write an extensible library](lesson1.md), we created this library:

%(example1.jsonnet)s

This library is quite verbose as the author has to provide the `apiVersion`, `kind` and
other attributes.

To simplify this, the community has created a Kubernetes client library for Jsonnet called
[`k8s-libsonnet`](https://github.com/jsonnet-libs/k8s-libsonnet). By leveraging this
client library, the author can provide an abstraction that can work across most Kubernetes
versions.

---

Let's install `k8s-libsonnet` with jsonnet-bundler and import it:

`$ jb install https://github.com/jsonnet-libs/k8s-libsonnet/1.23@main`

Note the alternative naming pattern ending on `1.23`, referencing the Kubernetes version
this was generated for.

%(example2/lib/k.libsonnet)s

The most common convention to work with this is to provide `lib/k.libsonnet` as
a shortcut.

%(example2/example1.jsonnet)s

Many libraries have a line `local k = import 'k.libsonnet'` to refer to this
library.



