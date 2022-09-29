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

### Testing the webserver library

#### `new()`

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

The `new()` function allows us to modify the `replicas` on the deployment, this will go
into the 'actual' part of the test case.

On the 'expected' part `base` is added with only the `replicas` attribute modified.

This test ensures only the replicas are changed, it also reinforces the values tested in
the 'Basic' test.

#### `withImages()`

%(example1/example4.jsonnet)s
%(example1/example4.jsonnet.output)s

Testing `withImages()` is a bit more complex. In the library this function modifies the
hidden `container::` field, which eventually gets added to the deployment in `new()`
through late-initialization.

Again `new()` is called to set the 'actual' part, this time `withImages()` is
concatenated to get a deployment with an alternative image.

On the 'expected' side the container with name `httpd` in the deployment needs to be
modified with the new image name, using the `mapContainerWithName` helper function to
keep the test cases readable.

Note that `mapContainerWithName` also preserves any other containers that may exist in
the deployment, future-proofing the unit tests.

### Test-driven development

Let's write a test for a new function `webserver.withImagePullPolicy(policy)`, which can
then be added as a feature to the library.

%(example1/example5.jsonnet)s

The new test 'Set imagePullPolicy' is very similar to 'Set alternative image'.

To use the same `base`, `new()` is concatenated with
`withImagePullPolicy('Always')` on 'actual'.

On 'expected' it uses the `mapWithContainerName` helper to set `imagePullPolicy` on
the `httpd` container.

---

%(example1/lib/webserver/wrong1.libsonnet)s

Extending the library (referenced as `main`) with the `withImagePullPolicy()` function is
quite straightforward.

---

%(example1/example5.jsonnet.output)s

Oh no, running the test shows a failure, how did that happen? The difference between
expected and actual result can be found in the output...

Turns out that the `test.expect.eq` function output is quite inconvenient, let's improve
that.

---

%(example1/example6.jsonnet)s

To replace `test.expect.eq`, a new 'test' function needs to be created. This can be done
with `test.expect.new(satisfy, message)`.

The `satisfy` function should return a boolean with `actual` and `expected` as arguments.

The `message` function returns a string and also accepts the `actual` and `expected`
results as arguments, these can be used to display the results in the error message.

---

%(example1/example6.jsonnet.output)s

The output is now a bit more convenient. It turns out that the `container` is being
replaced completely instead of having `imagePullPolicy` set.

---

%(example1/lib/webserver/wrong1.libsonnet)s

Can you spot the mistake?

---

%(example1/lib/webserver/correct.libsonnet)s

Turns out a `+` was forgotten on `container+:`.

---

%(example1/example7.jsonnet.output)s

With that fixed, the test suite succeeds.

### Pulling it together

```
example2/lib/webserver/
├── main.libsonnet
├── Makefile
└── test
    ├── base.json
    ├── jsonnetfile.json
    ├── lib/k.libsonnet
    └── main.libsonnet
```

With the test cases written, let's pull it all together in a `test/` subdirectory so that
the test dependencies from `jsonnetfile.json` are not required to install the library.

---

%(example2/lib/webserver/Makefile)s
%(example2/lib/webserver/make_test.output)s

With a `test` target in a Makefile, running the test cases becomes trivial.

### Pitfalls

Just like with any test framework, a unit test can be written in such a way that they
succeed while not actually validating the unit.

#### Testing individual attributes

%(example1/pitfall1.jsonnet)s
%(example1/pitfall1.jsonnet.output)s

While the unit tests here are valid on their own, they only validate individual
attributes. They won't catch any changes `withImagePullPolicy()` might make to other
attributes.

---

%(example1/lib/webserver/wrong2.libsonnet)s

For example, here `withImagePullPolicy()` function also changes `name` on the
`container` while this was explicitly tested on the 'simple' use case.

---

%(example1/pitfall2.jsonnet)s

To cover for the name (and other tests), the unit tests for 'simple' need to be repeated
for the 'imagePull' use case, resulting in an exponential growth of test case as the
library gets extended.

---

%(example1/pitfall2.jsonnet.output)s

Adding the test shows the expected failure.

#### Testing hidden attributes

%(example1/pitfall3.jsonnet)s
%(example1/pitfall3.jsonnet.output)s

While a unit test can access and validate the content of a hidden attribute, it is likely
not useful. From a testing perspective, the hidden attributes should be considered
'internals' to the function.

As Jsonnet does late-initialization before returning a JSON, validating the output should
also be done on all visible attributes it might affect.

---

%(example1/lib/webserver/wrong2.libsonnet)s

For example, here the `withImagePullPolicy()` function makes the `container` visible in
the output, changing the intended behavior of `new()`.
