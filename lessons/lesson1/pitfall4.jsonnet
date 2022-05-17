local webpage1 = {
  _images:: {
    httpd: 'httpd:2.4',
  },
  webpage1: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'webpage1',
    },
    spec: {
      replicas: 1,
      template: {
        spec: {
          containers: [{
            name: 'webserver',
            image: $._images.httpd,
          }],
        },
      },
    },
  },
};

local webpage2 = {
  _images:: {
    httpd: 'httpd:2.5',
  },
  webpage2: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'webpage2',
    },
    spec: {
      replicas: $._config.httpd_replicas,
      template: {
        spec: {
          containers: [{
            name: 'webserver',
            image: $._images.httpd,
          }],
        },
      },
    },
  },
};

webpage1 + webpage2 + {
  _config:: {
    httpd_replicas: 1,
  },
}
