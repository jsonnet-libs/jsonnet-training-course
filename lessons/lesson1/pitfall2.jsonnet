local webserver = {
  local base = self,

  _config:: {
    name: error 'provide name',
    replicas: 1,
  },

  _images:: {
    httpd: 'httpd:2.4',
  },

  container:: {
    name: 'httpd',
    image: base._images.httpd,
  },

  deployment: {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: base._config.name,
    },
    spec: {
      replicas: base._config.replicas,
      template: {
        spec: {
          containers: [
            base.container,
          ],
        },
      },
    },
  },
};

webserver {
  _config+: {
    name: 'wonderful-webserver',
  },
  _images+: {
    httpd: 'httpd:2.5',
  },
}
