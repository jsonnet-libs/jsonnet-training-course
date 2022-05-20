###  <a id="reusable-library" href="#reusable-library">Creating a reusable library</a>

Let's start with a simple `Deployment` of a webserver:

%(example1.jsonnet)s

A `Deployment` needs a number of configuration options, most importantly a unique `name`
and an array of `containers`

The `name` attribute exists on both the `metadata` and the first container. To refer to
these without ambiguity we can use a dot-notation, so referring can become more explicit
with `metadata.name` and `spec.template.spec.containers[0].name`.

---

Let's wrap this into a small `webserver` library and parameterize the name because
'webserver' may be a bit too generic:

%(example2.jsonnet)s

The `local` keyword makes this part of the code only available within this file, it is
often used for importing libraries from other files, for example `local myapp = import
'myapp.libsonnet';`.

The Deployment is wrapped into a `new()` function with a `name` and an optional
`replicas` arguments, this configures `metadata.name` and `spec.replicas`
respectively.

---

Let's add another function to modify the image of the httpd container:

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

To expose the webserver, a port is configured below. Now imagine that you are not the
author of this library and want to change the `ports` attribute.

%(example6.jsonnet)s

The author has not provided a function for that however, unlike Helm charts, it is not
necessary to fork the library to make this change. Jsonnet allows you to change any
attribute after the fact by concatenating a 'patch'. The `container+:` will maintain the
visibility of the `container` attribute while `ports:` will change the value of
`container.ports`.

This trait of Jsonnet keeps a balance between library authors providing a useful library
and users to extend it easily. Authors don't need to think about every use case out
there, they can apply [YAGNI](https://www.martinfowler.com/bliki/Yagni.html) and keep the
library code terse and maintainable without sacrificing extensibility.

---

### <a id="common-pitfalls" href="#common-pitfalls">Common pitfalls when creating libraries</a>

Avoid the 'builder' pattern:

%(pitfall1.jsonnet)s

Notice the odd `withImage():: self + {}` structure within `new()`.

This practice nests functions in the newly created object, allowing the user to 'chain'
functions to modify `self`. However this comes at a performance impact in the Jsonnet
interpreter and should be avoided.

---

A common pattern are libraries that use the `_config` and `_images` keys. This supposedly
attempts to differentiate between 'public' and 'private' APIs on libraries. However the
underscore prefix has no real meaning in jsonnet, at best it is a convention with implied
meaning.

Applying the convention to above library would make it look like this:

%(pitfall2.jsonnet)s

This convention attempts to provide a 'stable' API through the `_config` and `_images`
parameters, implying that patching other attributes will not be supported. However the
'public' attributes (indicated by the `_` prefix) are not more public or private than the
'private' attributes as they exists the same space. To make the `name` parameter
a required argument, an `error` is returned if it is not set in `_config`. 

It is comparable to the `values.yaml` in Helm charts, however Jsonnet does not face the
same limitations and as mentioned before users can modify the final output after the fact
either way.

---

This pattern also has an impact on extensibility. When introducing a new attribute, the
author needs to take into account that users might not want the same default.

%(pitfall3.jsonnet)s

This can be accomplished with imperative statements, however these pile up over time and
make the library brittle and hard to read. In this example the default for
`imagePullPolicy` is `null`, the author avoids adding an additional boolean parameter
(`_config.imagePullPolicyEnabled` for example) with the drawback that no default value can
be provided.

---

In the object-oriented library this can be done with a new function:

%(example7.jsonnet)s

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

%(pitfall4.jsonnet)s

This pattern makes it hard to determine which library is consuming which attribute. On top
of that libraries can influence each other unintentionally. 

In this example:
- `_config.httpd_replicas` is only consumed by `webserver2` while it seems to apply to both.
- `_image.httpd` is set on both libraries, however `webserver2` overrides the image of
    `webserver1` as it was concatenated later.

This practice comes from an anti-pattern to merge several libraries on top of each other
and refer to attributes that need to be set elsewhere. Or in other words, `$` promotes the
concept known as 'globals' in other programming libraries. It is best to avoid this as it
leads to spaghetti code.
