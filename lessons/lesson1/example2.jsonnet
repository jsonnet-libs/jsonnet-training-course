local webserver = {
  new(name, replicas=1): {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
    },
    spec: {
      replicas: replicas,
      selector: {
        matchLabels: {
          component: 'server',
        },
      },
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
};

webserver.new('wonderful-webserver')
