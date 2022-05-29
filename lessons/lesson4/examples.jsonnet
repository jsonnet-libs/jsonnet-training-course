local example = (import 'coursonnet.libsonnet').example;

[
  example.new(
    'example1/example1.jsonnet',
    importstr './example1/example1.jsonnet',
  ),

  example.new(
    'example1/vendor/github.com/Duologic/privatebin-libsonnet/main.libsonnet',
    importstr './example1/vendor/github.com/Duologic/privatebin-libsonnet/main.libsonnet',
  ),

  example.new(
    'example1/lib/privatebin/main.libsonnet',
    importstr './example1/lib/privatebin/main.libsonnet',
  ),

  example.new(
    'example1/example2.jsonnet',
    importstr './example1/example2.jsonnet',
  ),

  example.new(
    'example2/lib/privatebin/main.libsonnet',
    importstr './example2/lib/privatebin/main.libsonnet',
  ),

  example.new(
    'usecase-pentagon/lib/pentagon/example1.libsonnet',
    importstr './usecase-pentagon/lib/pentagon/example1.libsonnet',
  ),

  example.new(
    'usecase-pentagon/example1.jsonnet',
    importstr './usecase-pentagon/example1.jsonnet',
  ),

  example.new(
    'usecase-pentagon/lib/pentagon/example2.libsonnet',
    importstr './usecase-pentagon/lib/pentagon/example2.libsonnet',
  ),

  example.new(
    'example3/jsonnetfile.json',
    importstr './example3/jsonnetfile.json',
    type='json',
  ),
]
