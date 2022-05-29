local privatebin = import 'github.com/Duologic/privatebin-libsonnet/main.libsonnet';
local k = import 'k.libsonnet';

privatebin
{
  withPort(port): {
    container+:
      k.core.v1.container.withPorts([
        k.core.v1.containerPort.newNamed(
          name='http',
          containerPort=port
        ),
      ]),
  },
}
