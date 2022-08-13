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
