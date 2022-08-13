local k = import 'k.libsonnet';
local main = import 'main.libsonnet';

main {
  withImagePullPolicy(policy): {
    container+:
      k.core.v1.container.withImagePullPolicy(policy),
  },
}
