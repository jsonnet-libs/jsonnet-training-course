Let's unit test the webserver library from the first exercise.

%(example1/lib/webserver/main.libsonnet)s

This library provides a number of functions to create a webserver. Each function
eventually renders a bit of JSON. The `withImages()` function is supposed to be mixed in
with the `new()`. While doing maintenance on this library or adding new features,
a number of things could go wrong. A few unit tests can catch unintended changes early.

---

%(example1/base.json)s

The output of the webserver deployment will look like this. Note that it doesn't include
the hidden `container` field. This rendered representation will be used as the base for
the unit tests.

### Initializing Testonnet

For the unit tests, the [Testonnet](https://github.com/jsonnet-libs/testonnet) library
provides a few primitives to get us started.

`$ jb install github.com/jsonnet-libs/testonnet`

Check out the [docs](https://github.com/jsonnet-libs/testonnet/blob/master/docs/README.md) for Testonnet.

---

%(example1/example1.jsonnet)s

A test suite is initialized by calling `new(name)`. The `name` will be printed during
execution to help us find failing test cases.

When a test case fails, Testonnet will use `error` to ensure a non-zero exit code. This
has the side effect that the corresponding stack trace will be from the Testonnet
library, rather than the failing test. When using `std.thisFile` in the `name`, it will
be easier to find the failing test case.

---

%(example1/example1.jsonnet.output)s

Running the test suite can be done with this:

`$ jsonnet -J vendor -J lib example1.jsonnet`

The output will either show the failing test cases or count the successful test.

---

### Testing `new()`

%(example1/example2.jsonnet)s
%(example1/example2.jsonnet.output)s

`test.case.new(name, test)` adds a new test case to the suite. The `name` can be an
arbitrary string, `test` is an object that can created with `test.expect`. In this
example `test.expect.eq` compares 2 objects with the expectation that they are equal.

The output from `webserver.new()` is compared to the rendered representation. Running the
test suite returns a successful test.

---

%(example1/example3.jsonnet)s
%(example1/example3.jsonnet.output)s

The `new()` function allows us to modify the `replicas` on the deployment. The left side
of the comparison will represent that.

On the right side `base` is added with only the `replicas` attribute modified.

This test ensures only the replicas are changed, it also reinforces the values tested in
the 'Basic' test.

### Testing `withImages()`

%(example1/example4.jsonnet)s
%(example1/example4.jsonnet.output)s

Testing `withImages()` is a bit more complex. In the library this function modifies the
hidden `container::` field, which eventually gets added to the deployment in `new()`
through late-initialization.

On the left side again `new()` is called, this time `withImages()` is concatenated to get
a deployment with an alternative image.

On the right hand the container with name `httpd` in the deployment needs to be modified
with the new image name, using the `mapContainerWithName` helper function to keep the
test cases readable.


