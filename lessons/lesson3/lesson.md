In [Write an extensible library](lesson1.md), we created this library:

%(example1.jsonnet)s

This library is quite verbose as the author has to provide the `apiVersion`, `kind` and
other attributes.

To simplify this, the community has created a Kubernetes client library for Jsonnet called
[`k8s-libsonnet`](https://github.com/jsonnet-libs/k8s-libsonnet). By leveraging this
client library, the author can provide an abstraction that can work across most Kubernetes
versions.

Now go ahead with the `k8s-libsonnet` library and work out on your own with the resources
in these lessons:

1. [Write an extensible library](lesson1.md)
1. [Understanding Package management](lesson2.md)

Find the steps to a solution below.

### Solution

> Examples below expect to have an environment with `export JSONNET_PATH="lib/:vendor/"`

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

---

Let's rewrite the container following the
[documentation](https://jsonnet-libs.github.io/k8s-libsonnet/1.23/core/v1/container/):

%(example2/example2.jsonnet)s

The library has grouped a number of functions under `k.core.v1.container`, we'll use the
`new(name, image)` function here, this makes it concise. Additionally the `withImage()` function uses the function with the same name in the library.

---

And now for the [deployment](https://jsonnet-libs.github.io/k8s-libsonnet/1.23/apps/v1/deployment/):

%(example2/example3.jsonnet)s

The `new(name, replicas, images)` function makes things even more concise. The `new()`
function is actually a custom shortcut with the most common parameters for a deployment.

Note that we've removed `local base = self,`, this was not longer needed as the reference
to `self.container` can now be made inside the same object.

---

Having the library and execution together is not so useful, let's move it into a separate
library and import it again.

%(example2/lib/webserver/main.libsonnet)s

This removes the `local webserver` and moves the contents to the root of the file.

---

%(example2/example4.jsonnet)s

If we now `import` the library, we can access its functions just like before.

---

%(example2/example5.jsonnet)s

Or, if we want more instances, we can simply do so.
