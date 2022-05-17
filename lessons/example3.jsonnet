local webpage = {
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
              name: 'webserver',
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
            if container.name == 'webserver'
            then container { image: image }
            else container
            for container in containers
          ],
        },
      },
    },
  },
};

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')
