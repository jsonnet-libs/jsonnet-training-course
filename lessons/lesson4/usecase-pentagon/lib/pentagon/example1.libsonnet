local pentagon = import 'github.com/grafana/jsonnet-libs/pentagon/pentagon.libsonnet';

pentagon
{
  _config+:: {
    local this = self,
    pentagon+: {
      vault_address:
        if this.cluster_name == 'dev'
        then 'vault-dev.example.com'
        else 'vault-prod.example.com',
    },
  },
}
