local externalSecrets = import 'external-secrets-libsonnet/main.libsonnet';
local pentagon = import 'github.com/grafana/jsonnet-libs/pentagon/pentagon.libsonnet';

pentagon
{
  local this = self,

  // Remove/hide resources
  _config+:: {},
  deployment:: {},
  config_map:: {},
  rbac:: {},
  cluster_role:: {},
  cluster_role_binding:: {},

  local externalSecret = externalSecrets.nogroup.v1beta1.externalSecret,
  externalSecrets: std.sort([
    local mapping = this.pentagon_mappings_map[m];

    externalSecret.new(mapping.secretName)
    + externalSecret.spec.secretStoreRef.withName('vault-backend')
    + externalSecret.spec.secretStoreRef.withKind('SecretStore')
    + externalSecret.spec.target.withName(mapping.secretName)
    + externalSecret.spec.withDataFrom([
      {
        extract: {
          key: mapping.vaultPath,
        },
      },
    ])

    for m in std.objectFields(this.pentagon_mappings_map)
  ], function(e) if std.objectHasAll(e, 'idx') then e.idx else 0),
}
