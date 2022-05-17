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
};

webpage.new('wonderful-webpage')
