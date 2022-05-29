local example = (import 'coursonnet.libsonnet').example;
[
  example.new(
    'example1.jsonnet',
    importstr './example1.jsonnet',
    import './example1.jsonnet',
  ),

  example.new(
    'example2/lib/k.libsonnet',
    importstr './example2/lib/k.libsonnet',
  ),

  example.new(
    'example2/example1.jsonnet',
    importstr './example2/example1.jsonnet',
  ),

  example.new(
    'example2/example2.jsonnet',
    importstr './example2/example2.jsonnet',
  ),

  example.new(
    'example2/example3.jsonnet',
    importstr './example2/example3.jsonnet',
  ),

  example.new(
    'example2/example4.jsonnet',
    importstr './example2/example4.jsonnet',
  ),

  example.new(
    'example2/example5.jsonnet',
    importstr './example2/example5.jsonnet',
  ),

  example.new(
    'example2/lib/webserver/main.libsonnet',
    importstr './example2/lib/webserver/main.libsonnet',
  ),
]
