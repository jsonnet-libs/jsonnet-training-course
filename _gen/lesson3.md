# Exercise: rewrite a library with `k8s-libsonnet`

In the first lesson we've written a extensible library and in the second lesson we've
covered package management with jsonnet-bundler. In this lesson we'll combine what
we've learned and rewrite that library.


## Objectives

- Rewrite a library
- Vendor and use `k8s-libsonnet`
- Understand the `lib/k.libsonnet` convention

## Lesson

In [Write an extensible library](lesson1.md), we created this library:

```jsonnet
local webserver = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'httpd',
      image: 'httpd:2.4',
    },

    deployment: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: name,
      },
      spec: {
        replicas: replicas,
        template: {
          spec: {
            containers: [
              base.container,
            ],
          },
        },
      },
    },
  },

  withImage(image): {
    container+: { image: image },
  },
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')

// example1.jsonnet
```


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

```jsonnet
(import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet')

// example2/lib/k.libsonnet
```


The most common convention to work with this is to provide `lib/k.libsonnet` as
a shortcut.

```jsonnet
local k = import 'k.libsonnnet';

// example2/example1.jsonnet
```


Many libraries have a line `local k = import 'k.libsonnet'` to refer to this
library.





## Conclusion

TODO

