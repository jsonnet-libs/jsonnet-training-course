# Write a reusable library

Jsonnet gives us a lot of freedom to organize our libraries, there is no right or
wrong, however a well-organized library can get you a long way. While applying common
software development best-practices, we'll come up with an extensible library to
deploy a web page on Kubernetes.


## Objectives

- Write an object-oriented library
- Properly use keywords such as `local`, `super`, `self`, `null` and `$`
- Write for extensibility with `::`, `+:` and objects rather than arrays
- Write object-oriented with 'mixin' functions
- Apply YAGNI often
- Know how to avoid common pitfalls:
  - Builder pattern
  - `_config` and `_images` pattern
  - overuse of `$`


## Lesson

### Creating a reusable library

> TODO: move this note to the landing page/index
> Note: Don't worry if you don't know how Kubernetes works, it isn't a requirement to
> understand the Jsonnet examples.

Let's start with a simple `Deployment` of a webserver:

```jsonnet
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'webpage',
  },
  spec: {
    replicas: 1,
    template: {
      spec: {
        containers: [
          {
            name: 'webserver',
            image: 'httpd:2.4',
          },
        ],
      },
    },
  },
}

// example1.jsonnet
```
<small>[Try `example1.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=ewogIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICBraW5kOiAnRGVwbG95bWVudCcsCiAgbWV0YWRhdGE6IHsKICAgIG5hbWU6ICd3ZWJwYWdlJywKICB9LAogIHNwZWM6IHsKICAgIHJlcGxpY2FzOiAxLAogICAgdGVtcGxhdGU6IHsKICAgICAgc3BlYzogewogICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgIHsKICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgICAgIH0sCiAgICAgICAgXSwKICAgICAgfSwKICAgIH0sCiAgfSwKfQo=)</small>

A `Deployment` needs a number of configuration options, most importantly a unique `name`
and an array of `containers`

The `name` attribute exists on both the `metadata` and the first container. To refer to
these without ambiguity we can use a dot-notation, so referring can become more explicit
with `metadata.name` and `spec.template.spec.containers[0].name`.

---

Let's wrap this into a small `webpage` library and parameterize the name because
'webpage' may be a bit too generic:

<table>
<tr>
<td>

```jsonnet
local webpage = {
  new(name, replicas=1): {
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
            {
              name: 'webserver',
              image: 'httpd:2.4',
            },
          ],
        },
      },
    },
  },
};

webpage.new('wonderful-webpage')

// example2.jsonnet
```
<small>[Try `example2.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgIG1ldGFkYXRhOiB7CiAgICAgIG5hbWU6IG5hbWUsCiAgICB9LAogICAgc3BlYzogewogICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgc3BlYzogewogICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICB7CiAgICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgICAgaW1hZ2U6ICdodHRwZDoyLjQnLAogICAgICAgICAgICB9LAogICAgICAgICAgXSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAp9OwoKd2VicGFnZS5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykK)</small>

</td>
<td>
The `local` keyword makes this part of the code only available within this file, it is
often used for importing libraries from other files, for example `local myapp = import
'myapp.libsonnet';`.

The Deployment is wrapped into a `new()` function with a `name` and an optional
`replicas` arguments, this configures `metadata.name` and `spec.replicas`
respectively.
</td>
</tr>
</table>

---

Let's add another function to modify the image of the webserver container:

```jsonnet
local webpage = {
  new(name, replicas=1): {
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
            {
              name: 'webserver',
              image: 'httpd:2.4',
            },
          ],
        },
      },
    },
  },

  withImage(image): {
    local containers = super.spec.template.spec.containers,
    spec+: {
      template+: {
        spec+: {
          containers: [
            if container.name == 'webserver'
            then container { image: image }
            else container
            for container in containers
          ],
        },
      },
    },
  },
};

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')

// example3.jsonnet
```
<small>[Try `example3.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgIG1ldGFkYXRhOiB7CiAgICAgIG5hbWU6IG5hbWUsCiAgICB9LAogICAgc3BlYzogewogICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgc3BlYzogewogICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICB7CiAgICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgICAgaW1hZ2U6ICdodHRwZDoyLjQnLAogICAgICAgICAgICB9LAogICAgICAgICAgXSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBsb2NhbCBjb250YWluZXJzID0gc3VwZXIuc3BlYy50ZW1wbGF0ZS5zcGVjLmNvbnRhaW5lcnMsCiAgICBzcGVjKzogewogICAgICB0ZW1wbGF0ZSs6IHsKICAgICAgICBzcGVjKzogewogICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICBpZiBjb250YWluZXIubmFtZSA9PSAnd2Vic2VydmVyJwogICAgICAgICAgICB0aGVuIGNvbnRhaW5lciB7IGltYWdlOiBpbWFnZSB9CiAgICAgICAgICAgIGVsc2UgY29udGFpbmVyCiAgICAgICAgICAgIGZvciBjb250YWluZXIgaW4gY29udGFpbmVycwogICAgICAgICAgXSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAp9OwoKd2VicGFnZS5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykKKyB3ZWJwYWdlLndpdGhJbWFnZSgnaHR0cGQ6Mi41JykK)</small>

`withImage` is an optional 'mixin' function to modify the `Deployment`, notice how the
`new()` function did not have to change to make this possible. The function is intended to
be concatenated to `Deployment` object created by `new()`, it uses the `super` keyword to
access the `container` attribute.

As the `container` attribute is an array, it is not intuitive to modify an single entry.
We have to loop over the array, find the matching container and apply a patch. This is
quite verbose and hard to read.

---

Let's make the container a bit more accessible by moving it out of the `Deployment`:

```jsonnet
local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
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

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')

// example4.jsonnet
```
<small>[Try `example4.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgIH0sCgogICAgZGVwbG95bWVudDogewogICAgICBhcGlWZXJzaW9uOiAnYXBwcy92MScsCiAgICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgICAgbWV0YWRhdGE6IHsKICAgICAgICBuYW1lOiBuYW1lLAogICAgICB9LAogICAgICBzcGVjOiB7CiAgICAgICAgcmVwbGljYXM6IHJlcGxpY2FzLAogICAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgICBzcGVjOiB7CiAgICAgICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgICAgICBiYXNlLmNvbnRhaW5lciwKICAgICAgICAgICAgXSwKICAgICAgICAgIH0sCiAgICAgICAgfSwKICAgICAgfSwKICAgIH0sCiAgfSwKCiAgd2l0aEltYWdlKGltYWdlKTogewogICAgY29udGFpbmVyKzogeyBpbWFnZTogaW1hZ2UgfSwKICB9LAp9OwoKd2VicGFnZS5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykKKyB3ZWJwYWdlLndpdGhJbWFnZSgnaHR0cGQ6Mi41JykK)</small>

This makes the code a lot more succinct, no more loops and conditionals needed. The code
now reads more like a declarative document.

This introduces the `::` syntax, it hides an attribute from the final output but allows
for future changes to be applied to them. The `withImage` function uses `+:`, this
concatenates the image patch to the `container` attribute, using a single colon it
maintains the same hidden visibility as the `Deployment` object has defined.

The local `base` variable refers to the `self` keyword which returns the current object
(first curly brackets it encounters). The `deployment` then refers to `self.container`,
as `self` is late-bound any changes to `container` will be reflected in `deployment`.

---

To expose the webserver, we need to configure a port:

```jsonnet
local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
      image: 'httpd:2.4',
      ports: [{
        containerPort: 80,
      }],
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

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')

// example5.jsonnet
```
<small>[Try `example5.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgcG9ydHM6IFt7CiAgICAgICAgY29udGFpbmVyUG9ydDogODAsCiAgICAgIH1dLAogICAgfSwKCiAgICBkZXBsb3ltZW50OiB7CiAgICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgICBtZXRhZGF0YTogewogICAgICAgIG5hbWU6IG5hbWUsCiAgICAgIH0sCiAgICAgIHNwZWM6IHsKICAgICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgICAgdGVtcGxhdGU6IHsKICAgICAgICAgIHNwZWM6IHsKICAgICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICAgIGJhc2UuY29udGFpbmVyLAogICAgICAgICAgICBdLAogICAgICAgICAgfSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBjb250YWluZXIrOiB7IGltYWdlOiBpbWFnZSB9LAogIH0sCn07Cgp3ZWJwYWdlLm5ldygnd29uZGVyZnVsLXdlYnBhZ2UnKQorIHdlYnBhZ2Uud2l0aEltYWdlKCdodHRwZDoyLjUnKQo=)</small>

Now imagine that you are not the author of this library and want to change the `ports`
attribute.

```jsonnet
local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
      image: 'httpd:2.4',
      ports: [{
        containerPort: 80,
      }],
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

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')
+ {
  container+: {
    ports: [{
      containerPort: 8080,
    }],
  },
}

// example6.jsonnet
```
<small>[Try `example6.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgcG9ydHM6IFt7CiAgICAgICAgY29udGFpbmVyUG9ydDogODAsCiAgICAgIH1dLAogICAgfSwKCiAgICBkZXBsb3ltZW50OiB7CiAgICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgICBtZXRhZGF0YTogewogICAgICAgIG5hbWU6IG5hbWUsCiAgICAgIH0sCiAgICAgIHNwZWM6IHsKICAgICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgICAgdGVtcGxhdGU6IHsKICAgICAgICAgIHNwZWM6IHsKICAgICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICAgIGJhc2UuY29udGFpbmVyLAogICAgICAgICAgICBdLAogICAgICAgICAgfSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBjb250YWluZXIrOiB7IGltYWdlOiBpbWFnZSB9LAogIH0sCn07Cgp3ZWJwYWdlLm5ldygnd29uZGVyZnVsLXdlYnBhZ2UnKQorIHdlYnBhZ2Uud2l0aEltYWdlKCdodHRwZDoyLjUnKQorIHsKICBjb250YWluZXIrOiB7CiAgICBwb3J0czogW3sKICAgICAgY29udGFpbmVyUG9ydDogODA4MCwKICAgIH1dLAogIH0sCn0K)</small>

The author has not provided a function for that however, unlike Helm charts, it is not
necessary to fork the library to make this change. Jsonnet allows you to change any
attribute after the fact by concatenating a 'patch'. The `container+:` will maintain the
visibility of the `container` attribute while `ports:` will change the value of
`container.ports`.

This trait of Jsonnet allows to keep a balance between library authors providing a useful
library and users to extend it easily. Authors don't need to think about every use case
out there, they can apply [YAGNI (you aren't gonna need
it)](https://www.martinfowler.com/bliki/Yagni.html), this keeps the library code terse and
maintainable without sacrificing extensibility.

### Common pitfalls when creating libraries

Avoid the 'builder' pattern:

```jsonnet
local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
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

    withImage(image):: self + {
      container+: { image: image },
    },
  },
};

webpage.new('wonderful-webpage').withImage('httpd:2.5')

// pitfall1.jsonnet
```
<small>[Try `pitfall1.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgIH0sCgogICAgZGVwbG95bWVudDogewogICAgICBhcGlWZXJzaW9uOiAnYXBwcy92MScsCiAgICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgICAgbWV0YWRhdGE6IHsKICAgICAgICBuYW1lOiBuYW1lLAogICAgICB9LAogICAgICBzcGVjOiB7CiAgICAgICAgcmVwbGljYXM6IHJlcGxpY2FzLAogICAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgICBzcGVjOiB7CiAgICAgICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgICAgICBiYXNlLmNvbnRhaW5lciwKICAgICAgICAgICAgXSwKICAgICAgICAgIH0sCiAgICAgICAgfSwKICAgICAgfSwKICAgIH0sCgogICAgd2l0aEltYWdlKGltYWdlKTo6IHNlbGYgKyB7CiAgICAgIGNvbnRhaW5lcis6IHsgaW1hZ2U6IGltYWdlIH0sCiAgICB9LAogIH0sCn07Cgp3ZWJwYWdlLm5ldygnd29uZGVyZnVsLXdlYnBhZ2UnKS53aXRoSW1hZ2UoJ2h0dHBkOjIuNScpCg==)</small>

Notice the odd `withImage():: self + {}` structure.

This practice nests functions in the newly created object, allowing the user to 'chain'
functions to modify `self`. However this comes at a performance impact in the Jsonnet
interpreter and should be avoided.

---

A common pattern are libraries that use the `_config` and `_images` keys. This supposedly
attempts to differentiate between 'public' and 'private' APIs on libraries. However the
underscore prefix has no real meaning in jsonnet, at best it is a convention with implied
meaning.

Applying the convention to above library would make it look like this:

```jsonnet
local webpage = {
  local base = self,

  _config:: {
    name: error 'provide name',
    replicas: 1,
  },

  _images:: {
    httpd: 'httpd:2.4',
  },

  container:: {
    name: 'webserver',
    image: base._images.httpd,
  },

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: base._config.name,
    },
    spec: {
      replicas: base._config.replicas,
      template: {
        spec: {
          containers: [
            base.container,
          ],
        },
      },
    },
  },
};

webpage {
  _config+: {
    name: 'wonderful-webpage',
  },
  _images+: {
    httpd: 'httpd:2.5',
  },
}

// pitfall2.jsonnet
```
<small>[Try `pitfall2.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBsb2NhbCBiYXNlID0gc2VsZiwKCiAgX2NvbmZpZzo6IHsKICAgIG5hbWU6IGVycm9yICdwcm92aWRlIG5hbWUnLAogICAgcmVwbGljYXM6IDEsCiAgfSwKCiAgX2ltYWdlczo6IHsKICAgIGh0dHBkOiAnaHR0cGQ6Mi40JywKICB9LAoKICBjb250YWluZXI6OiB7CiAgICBuYW1lOiAnd2Vic2VydmVyJywKICAgIGltYWdlOiBiYXNlLl9pbWFnZXMuaHR0cGQsCiAgfSwKCiAgZGVwbG95bWVudDogewogICAgYXBpVmVyc2lvbjogJ2FwcHMvdjEnLAogICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgbWV0YWRhdGE6IHsKICAgICAgbmFtZTogYmFzZS5fY29uZmlnLm5hbWUsCiAgICB9LAogICAgc3BlYzogewogICAgICByZXBsaWNhczogYmFzZS5fY29uZmlnLnJlcGxpY2FzLAogICAgICB0ZW1wbGF0ZTogewogICAgICAgIHNwZWM6IHsKICAgICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgICAgYmFzZS5jb250YWluZXIsCiAgICAgICAgICBdLAogICAgICAgIH0sCiAgICAgIH0sCiAgICB9LAogIH0sCn07Cgp3ZWJwYWdlIHsKICBfY29uZmlnKzogewogICAgbmFtZTogJ3dvbmRlcmZ1bC13ZWJwYWdlJywKICB9LAogIF9pbWFnZXMrOiB7CiAgICBodHRwZDogJ2h0dHBkOjIuNScsCiAgfSwKfQo=)</small>

This convention attempts to provide a 'stable' API through the `_config` and `_images`
parameters, implying that patching other attributes will not be supported. However the
'public' attributes (indicated by the `_` prefix) are not more public or private than the
'private' attributes as they exists the same space. To make the `name` parameter
a required argument, an `error` is returned if it is not set in `_config`. 

This pattern is comparable to the `values.yaml` in Helm charts, however Jsonnet does not
face the same limitations and as said before users can modify the final output after the
fact either way.

This pattern also has an impact on extensibility. When introducing a new attribute, the
author needs to take into account that users might not want the same default.

```jsonnet
local webpage = {
  local base = self,

  _config:: {
    name: error 'provide name',
    replicas: 1,
    imagePullPolicy: null,
  },

  _images:: {
    httpd: 'httpd:2.4',
  },

  container:: {
    name: 'webserver',
    image: base._images.httpd,
  } + (
    if base._config.imagePullPolicy != null
    then { imagePullPolicy: base._config.imagePullPolicy }
    else {}
  ),

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: base._config.name,
    },
    spec: {
      replicas: base._config.replicas,
      template: {
        spec: {
          containers: [
            base.container,
          ],
        },
      },
    },
  },
};

webpage {
  _config+: {
    name: 'wonderful-webpage',
    imagePullPolicy: 'Always',
  },
  _images+: {
    httpd: 'httpd:2.5',
  },
}

// pitfall3.jsonnet
```
<small>[Try `pitfall3.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBsb2NhbCBiYXNlID0gc2VsZiwKCiAgX2NvbmZpZzo6IHsKICAgIG5hbWU6IGVycm9yICdwcm92aWRlIG5hbWUnLAogICAgcmVwbGljYXM6IDEsCiAgICBpbWFnZVB1bGxQb2xpY3k6IG51bGwsCiAgfSwKCiAgX2ltYWdlczo6IHsKICAgIGh0dHBkOiAnaHR0cGQ6Mi40JywKICB9LAoKICBjb250YWluZXI6OiB7CiAgICBuYW1lOiAnd2Vic2VydmVyJywKICAgIGltYWdlOiBiYXNlLl9pbWFnZXMuaHR0cGQsCiAgfSArICgKICAgIGlmIGJhc2UuX2NvbmZpZy5pbWFnZVB1bGxQb2xpY3kgIT0gbnVsbAogICAgdGhlbiB7IGltYWdlUHVsbFBvbGljeTogYmFzZS5fY29uZmlnLmltYWdlUHVsbFBvbGljeSB9CiAgICBlbHNlIHt9CiAgKSwKCiAgZGVwbG95bWVudDogewogICAgYXBpVmVyc2lvbjogJ2FwcHMvdjEnLAogICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgbWV0YWRhdGE6IHsKICAgICAgbmFtZTogYmFzZS5fY29uZmlnLm5hbWUsCiAgICB9LAogICAgc3BlYzogewogICAgICByZXBsaWNhczogYmFzZS5fY29uZmlnLnJlcGxpY2FzLAogICAgICB0ZW1wbGF0ZTogewogICAgICAgIHNwZWM6IHsKICAgICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgICAgYmFzZS5jb250YWluZXIsCiAgICAgICAgICBdLAogICAgICAgIH0sCiAgICAgIH0sCiAgICB9LAogIH0sCn07Cgp3ZWJwYWdlIHsKICBfY29uZmlnKzogewogICAgbmFtZTogJ3dvbmRlcmZ1bC13ZWJwYWdlJywKICAgIGltYWdlUHVsbFBvbGljeTogJ0Fsd2F5cycsCiAgfSwKICBfaW1hZ2VzKzogewogICAgaHR0cGQ6ICdodHRwZDoyLjUnLAogIH0sCn0K)</small>

This can be accomplished with imperative statements, however these pile up over time and
make the library brittle and hard to read. In this example the default for
`imagePullPolicy` is `null`, the author avoids adding an additional boolean parameter
(`_config.imagePullPolicyEnabled` for example) with the drawback that no default value can
be provided.

In the object-oriented library this can be done with a new function:

```jsonnet
local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
      image: 'httpd:2.4',
      ports: [{
        containerPort: 80,
      }],
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

  withImagePullPolicy(policy='Always'): {
    container+: { imagePullPolicy: policy },
  },
};

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')
+ webpage.withImagePullPolicy()

// example7.jsonnet
```
<small>[Try `example7.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgcG9ydHM6IFt7CiAgICAgICAgY29udGFpbmVyUG9ydDogODAsCiAgICAgIH1dLAogICAgfSwKCiAgICBkZXBsb3ltZW50OiB7CiAgICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgICBtZXRhZGF0YTogewogICAgICAgIG5hbWU6IG5hbWUsCiAgICAgIH0sCiAgICAgIHNwZWM6IHsKICAgICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgICAgdGVtcGxhdGU6IHsKICAgICAgICAgIHNwZWM6IHsKICAgICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICAgIGJhc2UuY29udGFpbmVyLAogICAgICAgICAgICBdLAogICAgICAgICAgfSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBjb250YWluZXIrOiB7IGltYWdlOiBpbWFnZSB9LAogIH0sCgogIHdpdGhJbWFnZVB1bGxQb2xpY3kocG9saWN5PSdBbHdheXMnKTogewogICAgY29udGFpbmVyKzogeyBpbWFnZVB1bGxQb2xpY3k6IHBvbGljeSB9LAogIH0sCn07Cgp3ZWJwYWdlLm5ldygnd29uZGVyZnVsLXdlYnBhZ2UnKQorIHdlYnBhZ2Uud2l0aEltYWdlKCdodHRwZDoyLjUnKQorIHdlYnBhZ2Uud2l0aEltYWdlUHVsbFBvbGljeSgpCg==)</small>

The `withImagePullPolicy()` function provides a more declarative approach to configure
this new option. In contrast to the approach above this new feature does not have to
modify the existing code, keeping a strong separation of concerns and reduces the risk of
introducing bugs.

At the same time functions provide a clean API for the end user and the author alike,
replacing the implied convention with declarative statements with required and optional
arguments. Calling the function implies that the user wants to set a value, the optional
arguments provides a default value `Always` to get the user going.

---

As you might have noticed, the `$` keyword is not used in any of these examples. In many
libraries it is used to refer to variables that still need to be set.

```jsonnet
local webpage1 = {
  _images:: {
    httpd: 'httpd:2.4',
  },
  webpage1: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'webpage1',
    },
    spec: {
      replicas: 1,
      template: {
        spec: {
          containers: [{
            name: 'webserver',
            image: $._images.httpd,
          }],
        },
      },
    },
  },
};

local webpage2 = {
  _images:: {
    httpd: 'httpd:2.5',
  },
  webpage2: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'webpage2',
    },
    spec: {
      replicas: $._config.httpd_replicas,
      template: {
        spec: {
          containers: [{
            name: 'webserver',
            image: $._images.httpd,
          }],
        },
      },
    },
  },
};

webpage1 + webpage2 + {
  _config:: {
    httpd_replicas: 1,
  },
}

// pitfall4.jsonnet
```
<small>[Try `pitfall4.jsonnet` in Jsonnet Playground](https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZTEgPSB7CiAgX2ltYWdlczo6IHsKICAgIGh0dHBkOiAnaHR0cGQ6Mi40JywKICB9LAogIHdlYnBhZ2UxOiB7CiAgICBhcGlWZXJzaW9uOiAnYXBwcy92MScsCiAgICBraW5kOiAnRGVwbG95bWVudCcsCiAgICBtZXRhZGF0YTogewogICAgICBuYW1lOiAnd2VicGFnZTEnLAogICAgfSwKICAgIHNwZWM6IHsKICAgICAgcmVwbGljYXM6IDEsCiAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgc3BlYzogewogICAgICAgICAgY29udGFpbmVyczogW3sKICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgIGltYWdlOiAkLl9pbWFnZXMuaHR0cGQsCiAgICAgICAgICB9XSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAp9OwoKbG9jYWwgd2VicGFnZTIgPSB7CiAgX2ltYWdlczo6IHsKICAgIGh0dHBkOiAnaHR0cGQ6Mi41JywKICB9LAogIHdlYnBhZ2UyOiB7CiAgICBhcGlWZXJzaW9uOiAnYXBwcy92MScsCiAgICBraW5kOiAnRGVwbG95bWVudCcsCiAgICBtZXRhZGF0YTogewogICAgICBuYW1lOiAnd2VicGFnZTInLAogICAgfSwKICAgIHNwZWM6IHsKICAgICAgcmVwbGljYXM6ICQuX2NvbmZpZy5odHRwZF9yZXBsaWNhcywKICAgICAgdGVtcGxhdGU6IHsKICAgICAgICBzcGVjOiB7CiAgICAgICAgICBjb250YWluZXJzOiBbewogICAgICAgICAgICBuYW1lOiAnd2Vic2VydmVyJywKICAgICAgICAgICAgaW1hZ2U6ICQuX2ltYWdlcy5odHRwZCwKICAgICAgICAgIH1dLAogICAgICAgIH0sCiAgICAgIH0sCiAgICB9LAogIH0sCn07Cgp3ZWJwYWdlMSArIHdlYnBhZ2UyICsgewogIF9jb25maWc6OiB7CiAgICBodHRwZF9yZXBsaWNhczogMSwKICB9LAp9Cg==)</small>

This pattern makes it hard to determine which library is consuming which attribute. On top
of that libraries can influence each other unintentionally. 

In this example:
- `_config.httpd_replicas` is only consumed by `webpage2` while it seems to apply to both.
- `_image.httpd` is set on both libraries, however `webpage2` overrides the image of
    `webpage1` as it was concatenated later.

This practice comes from an anti-pattern to merge several libraries on top of each other
and refer to attributes that need to be set elsewhere. Or in other words, `$` promotes the
concept known as 'globals' in other programming libraries. It is best to avoid this as it
leads to spaghetti code.


## Conclusion

TODO

