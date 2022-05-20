local webserver = {
  new(name, replicas=1): {
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
            {
              name: 'httpd',
              image: 'httpd:2.4',
            },
          ],
        },
      },
    },
  },

  withImage(image): {
    local containers = super.spec.template.spec.containers,
    spec+: {
      template+: {
        spec+: {
          containers: [
            if container.name == 'httpd'
            then container { image: image }
            else container
            for container in containers
          ],
        },
      },
    },
  },
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')
