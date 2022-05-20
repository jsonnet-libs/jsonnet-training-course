local webpage = {
  local base = self,

  _config:: {
    name: error 'provide name',
    replicas: 1,
    imagePullPolicy: null,
  },

  _images:: {
    httpd: 'httpd:2.4',
  },

  container:: {
    name: 'httpd',
    image: base._images.httpd,
  } + (
    if base._config.imagePullPolicy != null
    then { imagePullPolicy: base._config.imagePullPolicy }
    else {}
  ),

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
    imagePullPolicy: 'Always',
  },
  _images+: {
    httpd: 'httpd:2.5',
  },
}
