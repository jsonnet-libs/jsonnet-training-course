local k = import 'k.libsonnet';

local webserver = {
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
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')
