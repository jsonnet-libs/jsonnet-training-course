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

  example.new(
    'example2/example2.jsonnet',
    {},
    importstr './example2/example2.jsonnet',
  ) + { render: self.code },

  example.new(
    'example2/example3.jsonnet',
    {},
    importstr './example2/example3.jsonnet',
  ) + { render: self.code },

  example.new(
    'example2/example4.jsonnet',
    {},
    importstr './example2/example4.jsonnet',
  ) + { render: self.code },

  example.new(
    'example2/example5.jsonnet',
    {},
    importstr './example2/example5.jsonnet',
  ) + { render: self.code },

  example.new(
    'example2/lib/webserver/main.libsonnet',
    {},
    importstr './example2/lib/webserver/main.libsonnet',
  ) + { render: self.code },
]
