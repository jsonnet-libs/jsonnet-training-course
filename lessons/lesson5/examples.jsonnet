local example = (import 'coursonnet.libsonnet').example;
[
  example.new('./example1/example1.jsonnet'[2:], importstr './example1/example1.jsonnet', import './example1/example1.jsonnet'),
  example.new('./example1/example2.jsonnet'[2:], importstr './example1/example2.jsonnet', import './example1/example2.jsonnet'),
  example.new('./example1/example3.jsonnet'[2:], importstr './example1/example3.jsonnet', import './example1/example3.jsonnet'),
  example.new('./example1/example4.jsonnet'[2:], importstr './example1/example4.jsonnet', import './example1/example4.jsonnet'),
  example.new('./example1/example5.jsonnet'[2:], importstr './example1/example5.jsonnet', import './example1/example5.jsonnet'),
]
