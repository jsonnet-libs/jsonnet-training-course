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
