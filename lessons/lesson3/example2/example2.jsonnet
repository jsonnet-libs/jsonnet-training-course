local k = import 'k.libsonnet';

local webserver = {
  new(name, replicas=1): {
    local base = self,

    container::
      k.core.v1.container.new('httpd', 'httpd:2.4'),

    deployment: {
      apiVersion: 'apps/v1',
      kind: 'Deployment',
      metadata: {
        name: name,
      },
      spec: {
        replicas: replicas,
        template: {
          spec: {
            containers: [
              base.container,
            ],
          },
        },
      },
    },
  },

  withImage(image): {
    container+:
      k.core.v1.container.withImage(image),
  },
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')
