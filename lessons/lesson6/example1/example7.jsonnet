local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/correct.libsonnet';

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
    'Expected \n'
    + std.manifestJson(actual)
    + '\nto be\n'
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
