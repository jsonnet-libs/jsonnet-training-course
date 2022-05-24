{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'webserver',
  },
  spec: {
    replicas: 1,
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
}
