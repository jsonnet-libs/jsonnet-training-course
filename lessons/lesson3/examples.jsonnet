local example = (import 'coursonnet.libsonnet').example;
[
  example.new(
    'example1.jsonnet',
    import './example1.jsonnet',
    importstr './example1.jsonnet',
  ) + { render: self.code },

  example.new(
    'example2/lib/k.libsonnet',
    {},
    importstr './example2/lib/k.libsonnet',
  ) + { render: self.code },

  example.new(
    'example2/example1.jsonnet',
    {},
    importstr './example2/example1.jsonnet',
  ) + { render: self.code },

]
