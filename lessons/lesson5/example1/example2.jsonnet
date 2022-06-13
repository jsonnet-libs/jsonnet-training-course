local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';
local k = import 'k.libsonnet';

{
  '#':: d.pkg(
    name='webserver',
    url='github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1',
    help='`webserver` provides a basic webserver on Kubernetes',
    filename=std.thisFile,
  ),

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
