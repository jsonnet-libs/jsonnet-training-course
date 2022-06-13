local d = import 'github.com/jsonnet-libs/docsonnet/doc-util/main.libsonnet';
local k = import 'k.libsonnet';

{
  '#':: d.pkg(
    name='webserver',
    url='github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1',
    help='`webserver` provides a basic webserver on Kubernetes',
    filename=std.thisFile,
  ),

  '#new':: d.fn(
    help=|||
      `new` creates a Deployment object for Kubernetes

      * `name` sets the name for the Deployment object
      * `replicas` number of desired pods, defaults to 1
    |||,
    args=[
      d.arg('name', d.T.string),
      d.arg('replicas', d.T.number, 1),
    ]
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

  '#withImage':: d.fn(
    help='`withImage` modifies the image used for the httpd container',
    args=[
      d.arg('image', d.T.string),
    ]
  ),
  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
}
