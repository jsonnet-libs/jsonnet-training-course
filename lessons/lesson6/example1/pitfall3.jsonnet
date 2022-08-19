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
