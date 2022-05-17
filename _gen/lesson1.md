# Write a reusable library

Jsonnet gives us a lot of freedom to organize our libraries, there is no right or
wrong, however a well-organized library can get you a long way. While applying common
software development best-practices, we'll come up with an extensible library to
deploy a web page on Kubernetes.


## Objectives

- Properly use keywords such as `local`, `super`, `self`, `$` and `null`
- Write for extensibility with `::`, `+:` and objects rather than arrays
- Write object-oriented with 'mixin' functions
- Apply YAGNI often
- Know how to avoid common pitfalls:
  - Builder pattern
  - "private" variables
  - `prune` is recursive


## Lesson

<style>
body { margin-right: 50% }
li.L0, li.L1, li.L2, li.L3,
li.L5, li.L6, li.L7, li.L8 {
  list-style-type: decimal !important;
  }
</style>
<script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js"></script>

### Creating a reusable library

> TODO: move this note to the landing page/index
> Note: Don't worry if you don't know how Kubernetes works, it isn't a requirement to
> understand the Jsonnet examples.

Let's start with a simple `Deployment` of a webserver:

```jsonnet
// example1.jsonnet
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

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=ewogIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICBraW5kOiAnRGVwbG95bWVudCcsCiAgbWV0YWRhdGE6IHsKICAgIG5hbWU6ICd3ZWJwYWdlJywKICB9LAogIHNwZWM6IHsKICAgIHJlcGxpY2FzOiAxLAogICAgdGVtcGxhdGU6IHsKICAgICAgc3BlYzogewogICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgIHsKICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgICAgIH0sCiAgICAgICAgXSwKICAgICAgfSwKICAgIH0sCiAgfSwKfQo=" width="100%" height="500px"></iframe>
</details>


A `Deployment` needs a number of configuration options, most importantly a unique `name`
and an array of `containers`

The `name` attribute exists on both the `metadata` and the first container. To refer to
these without ambiguity we can use a dot-notation, so referring can become more explicit
with `metadata.name` and `spec.template.spec.containers[0].name`.

---

Let's wrap this into a small `webpage` library and parameterize the name because
'webpage' may be a bit too generic:

```jsonnet
// example2.jsonnet
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

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgIG1ldGFkYXRhOiB7CiAgICAgIG5hbWU6IG5hbWUsCiAgICB9LAogICAgc3BlYzogewogICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgc3BlYzogewogICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICB7CiAgICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgICAgaW1hZ2U6ICdodHRwZDoyLjQnLAogICAgICAgICAgICB9LAogICAgICAgICAgXSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAp9OwoKd2VicGFnZS5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykK" width="100%" height="500px"></iframe>
</details>


The `local` keyword makes this part of the code only available within this file, it is
often used for importing libraries from other files, for example `local myapp = import
'myapp.libsonnet';`.

The Deployment is wrapped into a `new()` function with a `name` and an optional
`replicas` arguments, this configures `metadata.name` and `spec.replicas`
respectively.

---

Let's add another function to modify the image of the webserver container:

```jsonnet
// example3.jsonnet
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

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgIG1ldGFkYXRhOiB7CiAgICAgIG5hbWU6IG5hbWUsCiAgICB9LAogICAgc3BlYzogewogICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgc3BlYzogewogICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICB7CiAgICAgICAgICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgICAgICAgICAgaW1hZ2U6ICdodHRwZDoyLjQnLAogICAgICAgICAgICB9LAogICAgICAgICAgXSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBsb2NhbCBjb250YWluZXJzID0gc3VwZXIuc3BlYy50ZW1wbGF0ZS5zcGVjLmNvbnRhaW5lcnMsCiAgICBzcGVjKzogewogICAgICB0ZW1wbGF0ZSs6IHsKICAgICAgICBzcGVjKzogewogICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICBpZiBjb250YWluZXIubmFtZSA9PSAnd2Vic2VydmVyJwogICAgICAgICAgICB0aGVuIGNvbnRhaW5lciB7IGltYWdlOiBpbWFnZSB9CiAgICAgICAgICAgIGVsc2UgY29udGFpbmVyCiAgICAgICAgICAgIGZvciBjb250YWluZXIgaW4gY29udGFpbmVycwogICAgICAgICAgXSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAp9OwoKd2VicGFnZS5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykKKyB3ZWJwYWdlLndpdGhJbWFnZSgnaHR0cGQ6Mi41JykK" width="100%" height="500px"></iframe>
</details>


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
// example4.jsonnet
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

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgIH0sCgogICAgZGVwbG95bWVudDogewogICAgICBhcGlWZXJzaW9uOiAnYXBwcy92MScsCiAgICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgICAgbWV0YWRhdGE6IHsKICAgICAgICBuYW1lOiBuYW1lLAogICAgICB9LAogICAgICBzcGVjOiB7CiAgICAgICAgcmVwbGljYXM6IHJlcGxpY2FzLAogICAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgICBzcGVjOiB7CiAgICAgICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgICAgICBiYXNlLmNvbnRhaW5lciwKICAgICAgICAgICAgXSwKICAgICAgICAgIH0sCiAgICAgICAgfSwKICAgICAgfSwKICAgIH0sCiAgfSwKCiAgd2l0aEltYWdlKGltYWdlKTogewogICAgY29udGFpbmVyKzogeyBpbWFnZTogaW1hZ2UgfSwKICB9LAp9OwoKd2VicGFnZS5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykKKyB3ZWJwYWdlLndpdGhJbWFnZSgnaHR0cGQ6Mi41JykK" width="100%" height="500px"></iframe>
</details>


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
// example5.jsonnet
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

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgcG9ydHM6IFt7CiAgICAgICAgY29udGFpbmVyUG9ydDogODAsCiAgICAgIH1dLAogICAgfSwKCiAgICBkZXBsb3ltZW50OiB7CiAgICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgICBtZXRhZGF0YTogewogICAgICAgIG5hbWU6IG5hbWUsCiAgICAgIH0sCiAgICAgIHNwZWM6IHsKICAgICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgICAgdGVtcGxhdGU6IHsKICAgICAgICAgIHNwZWM6IHsKICAgICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICAgIGJhc2UuY29udGFpbmVyLAogICAgICAgICAgICBdLAogICAgICAgICAgfSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBjb250YWluZXIrOiB7IGltYWdlOiBpbWFnZSB9LAogIH0sCn07Cgp3ZWJwYWdlLm5ldygnd29uZGVyZnVsLXdlYnBhZ2UnKQorIHdlYnBhZ2Uud2l0aEltYWdlKCdodHRwZDoyLjUnKQo=" width="100%" height="500px"></iframe>
</details>


Now imagine that you are not the author of this library and want to change the `ports`
attribute.

```jsonnet
// example6.jsonnet
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

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgICAgcG9ydHM6IFt7CiAgICAgICAgY29udGFpbmVyUG9ydDogODAsCiAgICAgIH1dLAogICAgfSwKCiAgICBkZXBsb3ltZW50OiB7CiAgICAgIGFwaVZlcnNpb246ICdhcHBzL3YxJywKICAgICAga2luZDogJ0RlcGxveW1lbnQnLAogICAgICBtZXRhZGF0YTogewogICAgICAgIG5hbWU6IG5hbWUsCiAgICAgIH0sCiAgICAgIHNwZWM6IHsKICAgICAgICByZXBsaWNhczogcmVwbGljYXMsCiAgICAgICAgdGVtcGxhdGU6IHsKICAgICAgICAgIHNwZWM6IHsKICAgICAgICAgICAgY29udGFpbmVyczogWwogICAgICAgICAgICAgIGJhc2UuY29udGFpbmVyLAogICAgICAgICAgICBdLAogICAgICAgICAgfSwKICAgICAgICB9LAogICAgICB9LAogICAgfSwKICB9LAoKICB3aXRoSW1hZ2UoaW1hZ2UpOiB7CiAgICBjb250YWluZXIrOiB7IGltYWdlOiBpbWFnZSB9LAogIH0sCn07Cgp3ZWJwYWdlLm5ldygnd29uZGVyZnVsLXdlYnBhZ2UnKQorIHdlYnBhZ2Uud2l0aEltYWdlKCdodHRwZDoyLjUnKQorIHsKICBjb250YWluZXIrOiB7CiAgICBwb3J0czogW3sKICAgICAgY29udGFpbmVyUG9ydDogODA4MCwKICAgIH1dLAogIH0sCn0K" width="100%" height="500px"></iframe>
</details>


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
// pitfall1.jsonnet
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

webpage
.new('wonderful-webpage')
.withImage('httpd:2.5')

```
<details>
  <summary><small>Try in Jsonnet Playground</small></summary>
  <iframe src="https://jsonnet-libs.github.io/playground/?code=bG9jYWwgd2VicGFnZSA9IHsKICBuZXcobmFtZSwgcmVwbGljYXM9MSk6IHsKICAgIGxvY2FsIGJhc2UgPSBzZWxmLAoKICAgIGNvbnRhaW5lcjo6IHsKICAgICAgbmFtZTogJ3dlYnNlcnZlcicsCiAgICAgIGltYWdlOiAnaHR0cGQ6Mi40JywKICAgIH0sCgogICAgZGVwbG95bWVudDogewogICAgICBhcGlWZXJzaW9uOiAnYXBwcy92MScsCiAgICAgIGtpbmQ6ICdEZXBsb3ltZW50JywKICAgICAgbWV0YWRhdGE6IHsKICAgICAgICBuYW1lOiBuYW1lLAogICAgICB9LAogICAgICBzcGVjOiB7CiAgICAgICAgcmVwbGljYXM6IHJlcGxpY2FzLAogICAgICAgIHRlbXBsYXRlOiB7CiAgICAgICAgICBzcGVjOiB7CiAgICAgICAgICAgIGNvbnRhaW5lcnM6IFsKICAgICAgICAgICAgICBiYXNlLmNvbnRhaW5lciwKICAgICAgICAgICAgXSwKICAgICAgICAgIH0sCiAgICAgICAgfSwKICAgICAgfSwKICAgIH0sCgogICAgd2l0aEltYWdlKGltYWdlKTo6IHNlbGYgKyB7CiAgICAgIGNvbnRhaW5lcis6IHsgaW1hZ2U6IGltYWdlIH0sCiAgICB9LAogIH0sCn07Cgp3ZWJwYWdlCi5uZXcoJ3dvbmRlcmZ1bC13ZWJwYWdlJykKLndpdGhJbWFnZSgnaHR0cGQ6Mi41JykK" width="100%" height="500px"></iframe>
</details>


This practice works with functions nested in the object, allowing the user to 'chain'
functions to modify `self`. However this comes at a performance impact in the Jsonnet
interpreter and should be avoided.

---


<script>
var pres = document.getElementsByTagName('pre');
for (i=0;i<pres.length; i++) {
  pres[i].className='prettyprint linenums';
}
PR.prettyPrint();
</script>



## Conclusion



