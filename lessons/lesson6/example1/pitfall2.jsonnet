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
