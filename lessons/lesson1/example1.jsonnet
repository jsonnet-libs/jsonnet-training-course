{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'webpage',
  },
  spec: {
    replicas: 1,
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
}
