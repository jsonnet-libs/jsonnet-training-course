local webserver = {
  new(name, replicas=1): {
    local base = self,

    container:: {
      name: 'httpd',
      image: 'httpd:2.4',
      ports: [{
        containerPort: 80,
      }],
    },
    apiVersion: 'apps/v1',

    kind: 'Deployment',
    metadata: {
      name: name,
    },
    spec: {
      selector: {
        matchLabels: {
          component: 'server',
        },
      },
      replicas: replicas,
      template: {
        metadata: {
          labels: {
            component: 'server',
          },
        },
        spec: {
          containers: [
            base.container,
          ],
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

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.4')
+ webserver.withImagePullPolicy()
