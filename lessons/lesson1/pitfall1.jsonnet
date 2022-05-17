local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
      image: 'httpd:2.4',
    },

    deployment: {
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
              base.container,
            ],
          },
        },
      },
    },

    withImage(image):: self + {
      container+: { image: image },
    },
  },
};

webpage.new('wonderful-webpage').withImage('httpd:2.5')
