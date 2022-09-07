{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'webserver',
  },
  spec: {
    replicas: 1,
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
            image: 'httpd:2.4',
          },
        ],
      },
    },
  },
}
