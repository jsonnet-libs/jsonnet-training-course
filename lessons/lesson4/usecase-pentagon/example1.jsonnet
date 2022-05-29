local pentagon = import 'pentagon/example1.libsonnet';

{
  pentagon: pentagon {
    _config+:: {
      cluster_name: 'dev',
      namespace: 'app1',
    },
    pentagon_mappings: [
      pentagon.pentagonKVMapping('path/to/secret', 'k8sSecretName'),
    ],
  },
}
