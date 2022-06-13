# Providing documentation with Docsonnet

In most programming languages documentation is done with the use of docstrings in
comments. However that is not possible with Jsonnet right now. To work around this, we
can use [Docsonnet](https://github.com/jsonnet-libs/docsonnet) and provide docstrings
as Jsonnet code.


## Objectives

- Write docstrings for Docsonnet
- Generate markdown documentation

## Lesson

### Writing docstrings

We'll continue with the webserver library from the exercise.

~~~jsonnet
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

// example1/example1.jsonnet
~~~


This library provides a number of functions to create a webserver. In docsonnet lingo,
this is called a 'package'. Each function has a few arguments which usually have a fixed
type. As Jsonnet itself is not a typed language, we'll simply try to document the type.

---

To get started, let's grab docsonnet's doc-util library. It provides a few functions to
write consistent docstrings for the different objects in Jsonnet.

`$ jb install github.com/jsonnet-libs/docsonnet/doc-util`

Note that the [docs for
doc-util](https://github.com/jsonnet-libs/docsonnet/blob/master/doc-util/README.md) are
also rendered by docsonnet.

---

~~~jsonnet
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';
local k = import 'k.libsonnet';

{
  '#':: d.pkg(
    name='webserver',
    url='github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1',
    help='`webserver` provides a basic webserver on Kubernetes',
    filename=std.thisFile,
  ),

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

// example1/example2.jsonnet
~~~


The docsonnet puts a claim on keys that start with a hash `#`. It assumes that keys
starting with a hash symbol is very uncommon. Additionally, it closely relates to how
comments are written.

The package definition is put in the `#` key without a value.

The `url` argument is the part that can be used to install this library with
jsonnet-bundler:

`$ jb install <url>`

In combination with the `url`, the `filename` refers to what should be imported, note the
neat `std.thisFile` shortcut so we don't have to remember to change the filename here if
we ever rename the file.

`import '<url>/<filename>'`

---

~~~jsonnet
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';
local k = import 'k.libsonnet';

{
  '#':: d.pkg(
    name='webserver',
    url='github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1',
    help='`webserver` provides a basic webserver on Kubernetes',
    filename=std.thisFile,
  ),

  '#new':: d.fn(
    help=|||
      `new` creates a Deployment object for Kubernetes

      * `name` sets the name for the Deployment object
      * `replicas` number of desired pods, defaults to 1
    |||,
    args=[
      d.arg('name', d.T.string),
      d.arg('replicas', d.T.number, 1),
    ]
  ),
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

  '#withImage':: d.fn(
    help='`withImage` modifies the image used for the httpd container',
    args=[
      d.arg('image', d.T.string),
    ]
  ),
  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
}

// example1/example3.jsonnet
~~~


Docstrings for other elements are put in the same key prefixed by a hash `#`, for example
the docstring for `new()` will be in the `#new` key. Functions can be documented with
`d.fn(help, args)`.

As the `help` text is quite long for this example, we're using multi line strings with
`|||`. This also improves the readability in the code. The `args` can be typed, values
for these are provided by `d.T.<type>` to increase consistency.

---

For the sake of this lesson, let's add a new `images` object with a few attributes:

~~~jsonnet
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';
local k = import 'k.libsonnet';

{
  '#':: d.pkg(
    name='webserver',
    url='github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1',
    help='`webserver` provides a basic webserver on Kubernetes',
    filename=std.thisFile,
  ),

  images: {
    apache: 'httpd:2.4',
    nginx: 'nginx:1.22',
  },

  '#new':: d.fn(
    help=|||
      `new` creates a Deployment object for Kubernetes

      * `name` sets the name for the Deployment object
      * `replicas` number of desired pods, defaults to 1
    |||,
    args=[
      d.arg('name', d.T.string),
      d.arg('replicas', d.T.number, 1),
    ]
  ),
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

  '#withImage':: d.fn(
    help='`withImage` modifies the image used for the httpd container',
    args=[
      d.arg('image', d.T.string),
    ]
  ),
  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
}

// example1/example4.jsonnet
~~~


The `images` key holds an object with additional webserver images.

It can be used in combination with `withImage`:

`webserver.withImage(webserver.images.nginx)`

---

~~~jsonnet
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';
local k = import 'k.libsonnet';

{
  '#':: d.pkg(
    name='webserver',
    url='github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1',
    help='`webserver` provides a basic webserver on Kubernetes',
    filename=std.thisFile,
  ),

  '#images':: d.obj(
    help=|||
      `images` provides images for common webservers

      Usage:

      ```
      webserver.new('my-nginx')
      + webserver.withImage(webserver.images.nginx)
      ```
    |||
  ),
  images: {
    '#apache':: d.val(d.T.string, 'Apache HTTP webserver'),
    apache: 'httpd:2.4',
    '#nginx':: d.val(d.T.string, 'Nginx HTTP webserver'),
    nginx: 'nginx:1.22',
  },

  '#new':: d.fn(
    help=|||
      `new` creates a Deployment object for Kubernetes

      * `name` sets the name for the Deployment object
      * `replicas` number of desired pods, defaults to 1
    |||,
    args=[
      d.arg('name', d.T.string),
      d.arg('replicas', d.T.number, 1),
    ]
  ),
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

  '#withImage':: d.fn(
    help='`withImage` modifies the image used for the httpd container',
    args=[
      d.arg('image', d.T.string),
    ]
  ),
  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
}

// example1/example5.jsonnet
~~~


Just like with functions, the key for the docstring gets prefixed by `#`. Objects can be
documented with `d.obj(help)`.

The attributes in this object can be documented with `d.val(type, help)`.

### Generating markdown docs

The doc-util library has a built-in rendering:

~~~jsonnet
local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';

d.render(import 'example5.jsonnet')

// example1/example7.jsonnet
~~~


The `render(obj)` function returns a format to output [multiple
files](https://jsonnet.org/learning/getting_started.html#multi).

---

```
{
  'README.md': "...",
  'path/to/example.md': "...",
}
```

---

Jsonnet can export those files:

`$ jsonnet --string --create-output-dirs --multi docs/ example7.jsonnet`

* `--string` because the Markdown output should be treated as a string instead of JSON.
* `--create-output-dirs` ensure directories for `path/to/example.md` get created.
* `--multi docs/` to set the output directory for multiple files to `docs/`.

Or in short:

`$ jsonnet -S -c -m docs/ example7.jsonnet`

Note that this overwrites but does not remove existing files. 

~~~makefile
.PHONY: docs
docs:
	rm -rf docs/ && \
	jsonnet -J ./vendor -S -c -m docs/ example7.jsonnet

// example1/Makefile
~~~


A simple Makefile target can be quite useful to contain these incantations.

---

> This can also be done without the additional Jsonnet file by using `jsonnet --exec`:
>
> `$ jsonnet -S -c -m docs/ --exec "(import 'doc-util/main.libsonnet').render(import 'example7.jsonnet')"`

---

The documentation for the webserver library will look like this:

~~~markdown
# package webserver

`webserver` provides a basic webserver on Kubernetes

## Install

```
jb install github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1@master
```

## Usage

```jsonnet
local webserver = import "github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1/example5.jsonnet"
```

## Index

* [`fn new(name, replicas=1)`](#fn-new)
* [`fn withImage(image)`](#fn-withimage)
* [`obj images`](#obj-images)

## Fields

### fn new

```ts
new(name, replicas=1)
```

`new` creates a Deployment object for Kubernetes

* `name` sets the name for the Deployment object
* `replicas` number of desired pods, defaults to 1


### fn withImage

```ts
withImage(image)
```

`withImage` modifies the image used for the httpd container

### obj images

`images` provides images for common webservers

Usage:

```
webserver.new('my-nginx')
+ webserver.withImage(webserver.images.nginx)
```


* `images.apache` (`string`): `"httpd:2.4"` - Apache HTTP webserver
* `images.nginx` (`string`): `"nginx:1.22"` - Nginx HTTP webserver

// example1/docs/README.md
~~~



## Conclusion

TODO


