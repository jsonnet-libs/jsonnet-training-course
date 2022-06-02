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

```jsonnet
(import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet')

// example2/lib/k.libsonnet
```


The most common convention to work with this is to provide `lib/k.libsonnet` as
a shortcut.

---

```jsonnet
local k = import 'k.libsonnet';

k.core.v1.container.new('container-name', 'container-image')

// example2/example1.jsonnet
```


Many libraries have a line `local k = import 'k.libsonnet'` to refer to this
library.

---

Let's rewrite the container following the
[documentation](https://jsonnet-libs.github.io/k8s-libsonnet/1.23/core/v1/container/):

```jsonnet
local k = import 'k.libsonnet';

local webserver = {
  new(name, replicas=1): {
    local base = self,

    container::
      k.core.v1.container.new('httpd', 'httpd:2.4'),

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
    container+:
      k.core.v1.container.withImage(image),
  },
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')

// example2/example2.jsonnet
```


The library has grouped a number of functions under `k.core.v1.container`, we'll use the
`new(name, image)` function here, this makes it concise. Additionally the `withImage()`
function uses the function with the same name in the library.

---

And now for the
[deployment](https://jsonnet-libs.github.io/k8s-libsonnet/1.23/apps/v1/deployment/):

```jsonnet
local k = import 'k.libsonnet';

local webserver = {
  new(name, replicas=1): {
    container::
      k.core.v1.container.new('httpd', 'httpd:2.4'),

    deployment:
      k.apps.v1.deployment.new(
        name,
        replicas,
        [self.container]
      ),
  },

  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')

// example2/example3.jsonnet
```


The `new(name, replicas, images)` function makes things even more concise. The `new()`
function is actually a custom shortcut with the most common parameters for a deployment.

Note that we've removed `local base = self,`, this was not longer needed as the reference
to `self.container` can now be made inside the same object.

---

Having the library and execution together is not so useful, let's move it into a separate
library and import it again.

```jsonnet
local k = import 'k.libsonnet';

{
  new(name, replicas=1): {
    container::
      k.core.v1.container.new('httpd', 'httpd:2.4'),

    deployment:
      k.apps.v1.deployment.new(
        name,
        replicas,
        [self.container]
      ),
  },

  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
}

// example2/lib/webserver/main.libsonnet
```


This removes the `local webserver` and moves the contents to the root of the file.

---

```jsonnet
local webserver = import 'webserver/main.libsonnet';

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')

// example2/example4.jsonnet
```


If we now `import` the library, we can access its functions just like before.

---

```jsonnet
local webserver = import 'webserver/main.libsonnet';

{
  webserver1:
    webserver.new('wonderful-webserver')
    + webserver.withImage('httpd:2.3'),

  webserver2:
    webserver.new('marvellous-webserver'),

  webserver3:
    webserver.new('incredible-webserver', 2),
}

// example2/example5.jsonnet
```


Or, if we want more instances, we can simply do so.


## Conclusion

This exercise showed how to make a library more succinct and readable. By using the
`k.libsonnet` abstract, the user has the option to use an alternative version of the
`k8s-libsonnet` library.


