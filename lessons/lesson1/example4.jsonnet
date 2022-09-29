local webserver = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'httpd',
      image: 'httpd:2.4',
    },

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
            base.container,
          ],
        },
      },
    },
  },

  withImage(image): {
    container+: { image: image },
  },
};

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.4')
