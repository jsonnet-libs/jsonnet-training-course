# Further developing libraries

When starting out with Jsonnet, it is very likely that you'll with existing code and
dependencies. Developing on these can seem confusing and tedious, however there are
several techniques that can help us iterate at different velocities.


## Objectives

- Wrap and extend a dependency locally
- Developing on upstream libraries

## Lesson

### Wrapping libraries

As shown in the [exercise](lesson3.md#solution), let's initialize a new project with
`k8s-libsonnet`:

`$ jb init`

`$ jb install github.com/jsonnet-libs/k8s-libsonnet/1.23@main`

`$ mkdir lib`

`$ echo "(import 'github.com/jsonnet-libs/k8s-libsonnet/1.23/main.libsonnet')" > lib/k.libsonnet`

And install
[`privatebin-libsonnet`](https://github.com/Duologic/privatebin-libsonnet):

`$ jb install github.com/Duologic/privatebin-libsonnet`

```jsonnet
local privatebin = import 'github.com/Duologic/privatebin-libsonnet/main.libsonnet';

{
  privatebin: privatebin.new(),
}

// example1/example1.jsonnet
```


This is relatively simple web application that exposes itself on port `8080`.

For the purpose of this exercise we want to run this application for different teams and
each team should be able to change the port to their liking.

---

```jsonnet
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
```


The library is relatively simple, it already exposes the `container` separate from the
`deployment` and we can pick the `name` and `image` when initializing it with `new()`.

One hurdle: the library does not expose a function to change the port. We could go about
and create a change request upstream, but considering this is a very trivial change it
might not be worth the time.

So, let's try to deal with it locally.

---

Let's create a local library in `lib/`:

```jsonnet
local privatebin = import 'github.com/Duologic/privatebin-libsonnet/main.libsonnet';
local k = import 'k.libsonnet';

privatebin
{
  withPort(port): {
    container+:
      k.core.v1.container.withPorts([
        k.core.v1.containerPort.newNamed(name='http', containerPort=port),
      ]),
  },
}

// example1/lib/privatebin/main.libsonnet
```


Here we import the vendored library and extend it, read it as `privatebin + {}`.

This will return the privatebin library extended with the `withPort()` function that will
change the ports of the `container`.

---

```jsonnet
local privatebin = import 'privatebin/main.libsonnet';

{
  privatebin:
    privatebin.new()
    + privatebin.withPort(9000),
}

// example1/example2.jsonnet
```


By changing the import, the `withPort()` function becomes available.

---


## Conclusion

TODO

