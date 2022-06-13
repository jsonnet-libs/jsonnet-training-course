### Writing docstrings

We'll continue with the webserver library from the exercise.

%(example1/example1.jsonnet)s

This library provides a number of functions to create a webserver. In docsonnet lingo, this
is called a 'package'. Each function has a few arguments which usually have a fixed type.
As Jsonnet itself is not a typed language, we'll simply try to document the type.

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

%(example1/example3.jsonnet)s

Docstrings for other elements are put in the same key prefixed by a hash `#`, for example
the docstring for `new()` will be in the `#new` key. Functions can be documented with
`d.fn(help, args)`.

As the `help` text is quite long for this example, we're using multi line strings with
`|||`. This also improves the readability in the code. The `args` can be typed, constants
for these are provided by `d.T.<type>` to increase consistency.

---

For the sake of this lesson, let's add a new `images` object with a few attributes:

%(example1/example4.jsonnet)s

The `images` key holds an object with additional webserver images.

It can be used in combination with `withImage`:

`webserver.withImage(webserver.images.nginx)`

---

%(example1/example5.jsonnet)s

Just like with functions, the key for the docstring gets prefixed by `#`. Objects can be
documented with `d.obj(help)`.

The attributes in this object can be documented with `d.val(type, help)`.

### Generating markdown docs

The doc-util library has a built-in rendering:

%(example1/example7.jsonnet)s

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

%(example1/Makefile)s

A simple Makefile target can be quite useful to contain these incantations.

---

> This can also be done without the additional Jsonnet file by using `jsonnet --exec`:
>
> `$ jsonnet -S -c -m docs/ --exec "(import 'doc-util/main.libsonnet').render(import 'example7.jsonnet')"`

---

The documentation for the webserver library will look like this:

%(example1/docs/README.md)s
