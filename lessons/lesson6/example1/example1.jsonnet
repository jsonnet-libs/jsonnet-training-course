local test = import 'testonnet/main.libsonnet';
local webserver = import 'webserver/main.libsonnet';

test.new(std.thisFile)
