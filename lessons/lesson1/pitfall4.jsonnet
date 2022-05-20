local webserver1 = {
  _images:: {
    httpd: 'httpd:2.4',
  },
  webserver1: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'webserver1',
    },
    spec: {
      replicas: 1,
      template: {
        spec: {
          containers: [{
            name: 'httpd',
            image: $._images.httpd,
          }],
        },
      },
    },
  },
};

local webserver2 = {
  _images:: {
    httpd: 'httpd:2.5',
  },
  webserver2: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'webserver2',
    },
    spec: {
      replicas: $._config.httpd_replicas,
      template: {
        spec: {
          containers: [{
            name: 'httpd',
            image: $._images.httpd,
          }],
        },
      },
    },
  },
};

webserver1 + webserver2 + {
  _config:: {
    httpd_replicas: 1,
  },
}
