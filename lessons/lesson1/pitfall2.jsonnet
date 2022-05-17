local webpage = {
  local base = self,

  _config:: {
    name: error 'provide name',
    replicas: 1,
  },

  _images:: {
    httpd: 'httpd:2.4',
  },

  container:: {
    name: 'webserver',
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

webpage {
  _config+: {
    name: 'wonderful-webpage',
  },
  _images+: {
    httpd: 'httpd:2.5',
  },
}
