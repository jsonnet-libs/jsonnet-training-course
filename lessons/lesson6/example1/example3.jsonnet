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
