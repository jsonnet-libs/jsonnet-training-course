local webserver = {
  new(name, replicas=1): {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
    },
    spec: {
      selector: {
        matchLabels: {
          component: 'server',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
            labels: {
              component: 'server',
            },
        },

        spec: {
          containers: [
            {
              name: 'httpd',
              image: 'httpd:2.3',
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
+ webserver.withImage('httpd:2.4')