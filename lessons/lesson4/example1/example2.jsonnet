local privatebin = import 'privatebin/main.libsonnet';

{
  privatebin:
    privatebin.new('backend')
    + privatebin.withPort(9000),
}
