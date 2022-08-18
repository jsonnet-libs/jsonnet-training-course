# Unit testing

TODO


## Objectives

- Basic usage
- Advanced usage
- Pitfalls

## Lesson

### Initializing Testonnet

Let's unit test the webserver library from the first exercise.

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

// example1/lib/webserver/main.libsonnet
~~~

~~~jsonnet
{
   "deployment": {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
         "name": "webserver1"
      },
      "spec": {
         "replicas": 1,
         "selector": {
            "matchLabels": {
               "name": "webserver1"
            }
         },
         "template": {
            "metadata": {
               "labels": {
                  "name": "webserver1"
               }
            },
            "spec": {
               "containers": [
                  {
                     "image": "httpd:2.4",
                     "name": "httpd"
                  }
               ]
            }
         }
      }
   }
}

// example1/base.json
~~~


This library provides a number of functions to create a webserver. Each function
eventually renders a bit of JSON. The `withImages()` function is supposed to be mixed in
with the `new()`. While doing maintenance on this library or adding new features,
a number of things could go wrong. A few unit tests can catch unintended changes early.

The webserver deployment will look like this. Note that it doesn't include the hidden
`container` field. We'll use this rendered representation as the base for the unit tests.


For this, we'll use the Testonnet library. It provides a few primitives to get us
started.

`$ jb install github.com/jsonnet-libs/testonnet`

Check out the [docs](https://github.com/jsonnet-libs/testonnet/blob/master/docs/README.md) for Testonnet.

---

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/main.libsonnet';

test.new(std.thisFile)

// example1/example1.jsonnet
~~~


A test suite is initialized by calling `new(name)`. The `name` will be printed during
execution to help us find failing test cases.

When a test case fails, Testonnet will use `error` to ensure a non-zero exit code. This
has the side effect that the corresponding stack trace will be from the Testonnet
library, rather than the failing test. When using `std.thisFile` in the `name`, it will
be easier to find the failing test case.

---

~~~jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example1.jsonnet
{
   "verify": "Passed 0 test cases"
}

// example1/example1.jsonnet.output
~~~


Running the test suite can be done with this:

`$ jsonnet -J vendor -J lib example1.jsonnet`

The output will either show the failing test cases or count the successful test.

---

### Testing `new()`

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/main.libsonnet';

local base = import 'base.json';

test.new(std.thisFile)
+ test.case.new(
  'Basic',
  test.expect.eq(
    webserver.new('webserver1'),
    base
  )
)

// example1/example2.jsonnet
~~~

~~~jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example2.jsonnet
{
   "verify": "Passed 1 test cases"
}

// example1/example2.jsonnet.output
~~~


`test.case.new(name, test)` adds a new test case to the suite. The `name` can be an
arbitrary string, `test` is an object that can created with `test.expect`. In this
example `test.expect.eq` compares 2 objects with the expectation that they are equal.

The output from `webserver.new()` is compared to the rendered representation. Running the
test suite returns a successful test.

---

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/main.libsonnet';

local webserverName = 'webserver1';
local base = import 'base.json';

test.new(std.thisFile)
+ test.case.new(
  'Basic',
  test.expect.eq(
    webserver.new(webserverName),
    base
  )
)
+ test.case.new(
  'Change default replicas',
  test.expect.eq(
    webserver.new(webserverName, 2),
    base { deployment+: { spec+: { replicas: 2 } } }
  )
)

// example1/example3.jsonnet
~~~

~~~jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example3.jsonnet
{
   "verify": "Passed 2 test cases"
}

// example1/example3.jsonnet.output
~~~


Let's add another test case. The `new()` function allows us to modify the `replicas` on
the deployment. We'll set that on one side of the comparison. On the othe side `base`
is added with only the `replicas` attribute modified.

This test ensures only the replicas are changed, it also reinforces the values tested in
the 'Basic' test.

### Testing `withImages()`

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/main.libsonnet';

local webserverName = 'webserver1';
local base = import 'base.json';

local mapContainerWithName(name, obj) =
  {
    local containers = super.spec.template.spec.containers,
    spec+: { template+: { spec+: { containers: [
      if c.name == name
      then c + obj
      else c
      for c in containers
    ] } } },
  };

test.new(std.thisFile)
+ test.case.new(
  'Basic',
  test.expect.eq(
    webserver.new(webserverName),
    base
  )
)
+ test.case.new(
  'Change default replicas',
  test.expect.eq(
    webserver.new(webserverName, 2),
    base { deployment+: { spec+: { replicas: 2 } } }
  )
)
+ test.case.new(
  'Set alternative image',
  test.expect.eq(
    webserver.new(webserverName)
    + webserver.withImage('httpd:2.5'),
    base { deployment+: mapContainerWithName('httpd', { image: 'httpd:2.5' }) }
  )
)

// example1/example4.jsonnet
~~~

~~~jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example4.jsonnet
{
   "verify": "Passed 3 test cases"
}

// example1/example4.jsonnet.output
~~~


Testing `withImages()` is a bit more complex. In the library this function modifies the
hidden `container::` field, which eventually gets added to the deployment in `new()`
through late-initialization.

On the left side we'll again call `new()` and append `withImages()` to get a deployment
with an alternative image. On the right hand the container with name `httpd` in the
deployment needs to be modified with the new image name, using the `mapContainerWithName`
helper function to keep the test cases readable.




## Conclusion

TODO


