<style>
body { margin-right: 50%% }
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

%(example1.jsonnet)s

A `Deployment` needs a number of configuration options, most importantly a unique `name`
and an array of `containers`

The `name` attribute exists on both the `metadata` and the first container. To refer to
these without ambiguity we can use a dot-notation, so referring can become more explicit
with `metadata.name` and `spec.template.spec.containers[0].name`.

---

Let's wrap this into a small `webpage` library and parameterize the name because
'webpage' may be a bit too generic:

%(example2.jsonnet)s

The `local` keyword makes this part of the code only available within this file, it is
often used for importing libraries from other files, for example `local myapp = import
'myapp.libsonnet';`.

The Deployment is wrapped into a `new()` function with a `name` and an optional
`replicas` arguments, this configures `metadata.name` and `spec.replicas`
respectively.

---

Let's add another function to modify the image of the webserver container:

%(example3.jsonnet)s

`withImage` is an optional 'mixin' function to modify the `Deployment`, notice how the
`new()` function did not have to change to make this possible. The function is intended to
be concatenated to `Deployment` object created by `new()`, it uses the `super` keyword to
access the `container` attribute.

As the `container` attribute is an array, it is not intuitive to modify an single entry.
We have to loop over the array, find the matching container and apply a patch. This is
quite verbose and hard to read.

---

Let's make the container a bit more accessible by moving it out of the `Deployment`:

%(example4.jsonnet)s

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

%(example5.jsonnet)s

Now imagine that you are not the author of this library and want to change the `ports`
attribute.

%(example6.jsonnet)s

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

%(pitfall1.jsonnet)s

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

