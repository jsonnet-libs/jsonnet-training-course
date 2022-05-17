local webpage = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'webserver',
      image: 'httpd:2.4',
      ports: [{
        containerPort: 80,
      }],
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
  },

  withImage(image): {
    container+: { image: image },
  },

  withImagePullPolicy(policy='Always'): {
    container+: { imagePullPolicy: policy },
  },
};

webpage.new('wonderful-webpage')
+ webpage.withImage('httpd:2.5')
+ webpage.withImagePullPolicy()
