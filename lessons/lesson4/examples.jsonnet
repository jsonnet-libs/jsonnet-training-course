local example = (import 'coursonnet.libsonnet').example;

[
  example.new(
    'example1/example1.jsonnet',
    {},
    importstr './example1/example1.jsonnet',
  ) + { render: self.code },
  example.new(
    'example1/vendor/github.com/Duologic/privatebin-libsonnet/main.libsonnet',
    {},
    importstr './example1/vendor/github.com/Duologic/privatebin-libsonnet/main.libsonnet',
  ) + { render: self.code },
  example.new(
    'example1/lib/privatebin/main.libsonnet',
    {},
    importstr './example1/lib/privatebin/main.libsonnet',
  ) + { render: self.code },
  example.new(
    'example1/example2.jsonnet',
    {},
    importstr './example1/example2.jsonnet',
  ) + { render: self.code },

  example.new(
    'usecase-pentagon/lib/pentagon/example1.libsonnet',
    {},
    importstr './usecase-pentagon/lib/pentagon/example1.libsonnet',
  ) + { render: self.code },
  example.new(
    'usecase-pentagon/example1.jsonnet',
    {},
    importstr './usecase-pentagon/example1.jsonnet',
  ) + { render: self.code },
  example.new(
    'usecase-pentagon/lib/pentagon/example2.libsonnet',
    {},
    importstr './usecase-pentagon/lib/pentagon/example2.libsonnet',
  ) + { render: self.code },

  example.new(
    'example3/jsonnetfile.json',
    {},
    importstr './example3/jsonnetfile.json',
    'json',
  ) + { render: self.code },
]
