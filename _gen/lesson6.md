# Unit testing

TODO


## Objectives

- Write unit tests in Jsonnet
- Do test-driven development
- Know how to avoid pitfalls

## Lesson

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


This library provides a number of functions to create a webserver. Each function
eventually renders a bit of JSON. The `withImages()` function is supposed to be mixed in
with the `new()`. While doing maintenance on this library or adding new features,
a number of things could go wrong. A few unit tests can catch unintended changes early.

---

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


The output of the webserver deployment will look like this. Note that it doesn't include
the hidden `container` field. This rendered representation will be used as the base for
the unit tests.

### Initializing Testonnet

For the unit tests, the [Testonnet](https://github.com/jsonnet-libs/testonnet) library
provides a few primitives to get us started.

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
# jsonnet -J lib -J vendor example1.jsonnet
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

### Testing the webserver library

#### `new()`

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
# jsonnet -J lib -J vendor example2.jsonnet
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
# jsonnet -J lib -J vendor example3.jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example3.jsonnet
{
   "verify": "Passed 2 test cases"
}

// example1/example3.jsonnet.output
~~~


The `new()` function allows us to modify the `replicas` on the deployment. The left side
of the comparison will represent that.

On the right side `base` is added with only the `replicas` attribute modified.

This test ensures only the replicas are changed, it also reinforces the values tested in
the 'Basic' test.

#### `withImages()`

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
# jsonnet -J lib -J vendor example4.jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example4.jsonnet
{
   "verify": "Passed 3 test cases"
}

// example1/example4.jsonnet.output
~~~


Testing `withImages()` is a bit more complex. In the library this function modifies the
hidden `container::` field, which eventually gets added to the deployment in `new()`
through late-initialization.

On the left side again `new()` is called, this time `withImages()` is concatenated to get
a deployment with an alternative image.

On the right hand the container with name `httpd` in the deployment needs to be modified
with the new image name, using the `mapContainerWithName` helper function to keep the
test cases readable.

Note that `mapContainerWithName` also preserves any other containers that may exist in
the deployment, future-proofing the unit tests.

### Test-driven development

Let's write a test for a new function `webserver.withImagePullPolicy(policy)`, which can
then be added as a feature to the library.

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/wrong1.libsonnet';

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
+ test.case.new(
  'Set imagePullPolicy',
  test.expect.eq(
    webserver.new(webserverName)
    + webserver.withImagePullPolicy('Always'),
    base { deployment+: mapContainerWithName('httpd', { imagePullPolicy: 'Always' }) }
  )
)

// example1/example5.jsonnet
~~~


The new test 'Set imagePullPolicy' is very similar to 'Set alternative image'.

To use the same `base`, `new()` is concatenated with
`withImagePullPolicy('Always')` on the left.

On the right it uses the `mapWithContainerName` helper to set `imagePullPolicy` on the
`httpd` container.

---

~~~jsonnet
local k = import 'k.libsonnet';
local main = import 'main.libsonnet';

main {
  withImagePullPolicy(policy): {
    container:
      k.core.v1.container.withImagePullPolicy(policy),
  },
}

// example1/lib/webserver/wrong1.libsonnet
~~~


Extending the library (referenced as `main`) with the `withImagePullPolicy()` function is
quite straightforward.

---

~~~jsonnet
# jsonnet -J lib -J vendor example5.jsonnet
RUNTIME ERROR: Failed 1/4 test cases:
Set imagePullPolicy: Expected {"deployment": {"apiVersion": "apps/v1", "kind": "Deployment", "metadata": {"name": "webserver1"}, "spec": {"replicas": 1, "selector": {"matchLabels": {"name": "webserver1"}}, "template": {"metadata": {"labels": {"name": "webserver1"}}, "spec": {"containers": [{"imagePullPolicy": "Always"}]}}}}} to be {"deployment": {"apiVersion": "apps/v1", "kind": "Deployment", "metadata": {"name": "webserver1"}, "spec": {"replicas": 1, "selector": {"matchLabels": {"name": "webserver1"}}, "template": {"metadata": {"labels": {"name": "webserver1"}}, "spec": {"containers": [{"image": "httpd:2.4", "imagePullPolicy": "Always", "name": "httpd"}]}}}}}
	vendor/testonnet/main.libsonnet:(78:11)-(84:13)	thunk from <object <anonymous>>
	vendor/testonnet/main.libsonnet:(74:7)-(87:8)	object <anonymous>
	Field "verify"	
	During manifestation	


// example1/example5.jsonnet.output
~~~


Oh no, running the test shows a failure, how did that happen? The difference between
expected and actual result can be found in the output...

Turns out that the `test.expect.eq` function output is quite inconvenient, let's improve
that.

---

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/wrong1.libsonnet';

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

local eqJson = test.expect.new(
  function(actual, expected) actual == expected,
  function(actual, expected)
    'Actual:\n'
    + std.manifestJson(actual)
    + '\nExpected:\n'
    + std.manifestJson(expected),
);

test.new(std.thisFile)
+ test.case.new(
  'Basic',
  eqJson(
    webserver.new(webserverName),
    base
  )
)
+ test.case.new(
  'Change default replicas',
  eqJson(
    webserver.new(webserverName, 2),
    base { deployment+: { spec+: { replicas: 2 } } }
  )
)
+ test.case.new(
  'Set alternative image',
  eqJson(
    webserver.new(webserverName)
    + webserver.withImage('httpd:2.5'),
    base { deployment+: mapContainerWithName('httpd', { image: 'httpd:2.5' }) }
  )
)
+ test.case.new(
  'Set imagePullPolicy',
  eqJson(
    webserver.new(webserverName)
    + webserver.withImagePullPolicy('Always'),
    base { deployment+: mapContainerWithName('httpd', { imagePullPolicy: 'Always' }) }
  )
)

// example1/example6.jsonnet
~~~


To replace `test.expect.eq`, a new 'test' function needs to be created. This can be done
with `test.expect.new(satisfy, message)`.

The `satisfy` function should return a boolean with `actual` and `expected` as arguments.

The `message` function returns a string and also accepts the `actual` and `expected`
results as arguments, these can be used to display the results in the error message.

---

~~~jsonnet
# jsonnet -J lib -J vendor example6.jsonnet
RUNTIME ERROR: Failed 1/4 test cases:
Set imagePullPolicy: Actual:
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
                            "imagePullPolicy": "Always"
                        }
                    ]
                }
            }
        }
    }
}
Expected:
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
                            "imagePullPolicy": "Always",
                            "name": "httpd"
                        }
                    ]
                }
            }
        }
    }
}
	vendor/testonnet/main.libsonnet:(78:11)-(84:13)	thunk from <object <anonymous>>
	vendor/testonnet/main.libsonnet:(74:7)-(87:8)	object <anonymous>
	Field "verify"	
	During manifestation	


// example1/example6.jsonnet.output
~~~


The output is now a bit more convenient. It turns out that the `container` is being
replaced completely instead of having `imagePullPolicy` set.

---

~~~jsonnet
local k = import 'k.libsonnet';
local main = import 'main.libsonnet';

main {
  withImagePullPolicy(policy): {
    container:
      k.core.v1.container.withImagePullPolicy(policy),
  },
}

// example1/lib/webserver/wrong1.libsonnet
~~~


Can you spot the mistake?

---

~~~jsonnet
local k = import 'k.libsonnet';
local main = import 'main.libsonnet';

main {
  withImagePullPolicy(policy): {
    container+:
      k.core.v1.container.withImagePullPolicy(policy),
  },
}

// example1/lib/webserver/correct.libsonnet
~~~


Turns out a `+` was forgotten on `container+:`.

---

~~~jsonnet
# jsonnet -J lib -J vendor example7.jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite example7.jsonnet
{
   "verify": "Passed 4 test cases"
}

// example1/example7.jsonnet.output
~~~


With that fixed, the test suite succeeds.

### Pitfalls

Just like with any test framework, a unit test can be written in such a way that they
succeed while not actually validating the unit.

#### Testing individual attributes

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/wrong2.libsonnet';

local simple = webserver.new('webserver1');
local imagePull =
  webserver.new('webserver1')
  + webserver.withImagePullPolicy('Always');

test.new(std.thisFile)
+ test.case.new(
  'Validate name',
  test.expect.eq(
    simple.deployment.metadata.name,
    'webserver1',
  )
)
+ test.case.new(
  'Validate image name',
  test.expect.eq(
    simple.deployment.spec.template.spec.containers[0].name,
    'httpd',
  )
)
+ test.case.new(
  'Validate imagePullPolicy',
  test.expect.eq(
    imagePull.deployment.spec.template.spec.containers[0].imagePullPolicy,
    'Always',
  )
)

// example1/pitfall1.jsonnet
~~~

~~~jsonnet
# jsonnet -J lib -J vendor pitfall1.jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite pitfall1.jsonnet
{
   "verify": "Passed 3 test cases"
}

// example1/pitfall1.jsonnet.output
~~~


While the unit tests here are valid on their own, they only validate individual
attributes. They won't catch any changes `withImagePullPolicy()` might make to other
attributes.

---

~~~jsonnet
local k = import 'k.libsonnet';
local main = import 'main.libsonnet';

main {
  withImagePullPolicy(policy): {
    container+:
      k.core.v1.container.withName(super.container.name + policy)
      + k.core.v1.container.withImagePullPolicy(policy),
  },
}

// example1/lib/webserver/wrong2.libsonnet
~~~


For example, here `withImagePullPolicy()` function also changes `name` on the
`container` while this was explicitly tested on the 'simple' use case.

---

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/wrong2.libsonnet';

local simple = webserver.new('webserver1');
local imagePull =
  webserver.new('webserver1')
  + webserver.withImagePullPolicy('Always');

test.new(std.thisFile)
+ test.case.new(
  'Validate name',
  test.expect.eq(
    simple.deployment.metadata.name,
    'webserver1',
  )
)
+ test.case.new(
  'Validate image name',
  test.expect.eq(
    simple.deployment.spec.template.spec.containers[0].name,
    'httpd',
  )
)
+ test.case.new(
  'Validate imagePullPolicy',
  test.expect.eq(
    imagePull.deployment.spec.template.spec.containers[0].imagePullPolicy,
    'Always',
  )
)
+ test.case.new(
  'Validate name',
  test.expect.eq(
    imagePull.deployment.metadata.name,
    'webserver1',
  )
)
+ test.case.new(
  'Validate image name',
  test.expect.eq(
    imagePull.deployment.spec.template.spec.containers[0].name,
    'httpd',
  )
)

// example1/pitfall2.jsonnet
~~~


To cover for the name (and other tests), the unit tests for 'simple' need to be repeated
for the 'imagePull' use case, resulting in an exponential growth of test case as the
library gets extended.

---

~~~jsonnet
# jsonnet -J lib -J vendor pitfall2.jsonnet
RUNTIME ERROR: Failed 1/5 test cases:
Validate image name: Expected httpdAlways to be httpd
	vendor/testonnet/main.libsonnet:(78:11)-(84:13)	thunk from <object <anonymous>>
	vendor/testonnet/main.libsonnet:(74:7)-(87:8)	object <anonymous>
	Field "verify"	
	During manifestation	


// example1/pitfall2.jsonnet.output
~~~


Adding the test shows the expected failure.

#### Testing hidden attributes

~~~jsonnet
local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/wrong3.libsonnet';

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
  'Set alternative image',
  test.expect.eq(
    (webserver.new(webserverName)
     + webserver.withImagePullPolicy('Always')).container,
    {
      name: 'httpd',
      image: 'httpd:2.4',
      imagePullPolicy: 'Always',
    }
  )
)

// example1/pitfall3.jsonnet
~~~

~~~jsonnet
# jsonnet -J lib -J vendor pitfall3.jsonnet
TRACE: vendor/testonnet/main.libsonnet:74 Testing suite pitfall3.jsonnet
{
   "verify": "Passed 2 test cases"
}

// example1/pitfall3.jsonnet.output
~~~


While a unit test can access and validate the content of a hidden attribute, it is likely
not useful. From a testing perspective, the hidden attributes should be considered
'internals' to the function.

As Jsonnet does late-initialization before returning a JSON, validating the output should
also be done on all visible attributes it might affect.

---

~~~jsonnet
local k = import 'k.libsonnet';
local main = import 'main.libsonnet';

main {
  withImagePullPolicy(policy): {
    container+:
      k.core.v1.container.withName(super.container.name + policy)
      + k.core.v1.container.withImagePullPolicy(policy),
  },
}

// example1/lib/webserver/wrong2.libsonnet
~~~


For example, here the `withImagePullPolicy()` function makes the `container` visible in
the output, changing the intended behavior of `new()`.


## Conclusion

TODO


