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
};

webserver.new('wonderful-webserver')
