We'll continue with the webserver library from the exercise.

%(example1/example1.jsonnet)s

This library provides a number of functions to create a webserver. In docsonnet lingo this
is called a 'package'. Each function has a few arguments which usually have a fixed type,
as Jsonnet itself is not a typed language we'll simply try to document the type.

---

To get started, let's grab docsonnet's doc-util library. It provides a few functions to
write consistent docstrings for the different objects in Jsonnet.

`$ jb install github.com/jsonnet-libs/docsonnet/doc-util`

Note that the [docs for
doc-util](https://github.com/jsonnet-libs/docsonnet/blob/master/doc-util/README.md) are
also rendered by docsonnet.

---

%(example1/example2.jsonnet)s

The docsonnet puts a claim on keys that start with a hash `#`. It assumes that keys
starting with a hash symbol is very uncommon, additionally it closely relates to how
comments are written.

The package definition is put in the `#` key without a value.

The `url` argument is the part that can be used to install this library with
jsonnet-bundler:

`$ jb install <url>`

In combination with the `url`, the `filename` refers to what should be imported, note the
neat `std.thisFile` shortcut so we don't have to remember to change the filename here if
we do so.

`import '<url>/<filename>'`

---

%(example1/example3.jsonnet)s

Docstrings for other elements are put in the same key prefixed by a hash `#`, for example
the docstring for `new()` will be in the `#new` key. Functions can be documented with
`d.fn(help, args)`.

As the `help` text is quite long for this example, we're using multi line strings with
`|||`. This also improves the readability in the code. The `args` can be typed, constants
for these are provided by `d.T.<type>` to increase consistency.

---

For the sake of this lesson, let's add an object and a few constants:

%(example1/example4.jsonnet)s

The `images` key holds an object with additional webserver images.

Just like with functions, the docstring key gets prefixed by `#`. Objects can be
documented with `d.obj(help)`.

Constants can be documented with `d.val(type, help)`.

---
