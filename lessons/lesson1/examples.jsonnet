local example = (import 'coursonnet.libsonnet').example;
[
  example.new('./example1.jsonnet'[2:], importstr './example1.jsonnet', import './example1.jsonnet')+example.withLink(),
  example.new('./example2.jsonnet'[2:], importstr './example2.jsonnet', import './example2.jsonnet')+example.withLink(),
  example.new('./example3.jsonnet'[2:], importstr './example3.jsonnet', import './example3.jsonnet')+example.withLink(),
  example.new('./example4.jsonnet'[2:], importstr './example4.jsonnet', import './example4.jsonnet')+example.withLink(),
  example.new('./example5.jsonnet'[2:], importstr './example5.jsonnet', import './example5.jsonnet')+example.withLink(),
  example.new('./example6.jsonnet'[2:], importstr './example6.jsonnet', import './example6.jsonnet')+example.withLink(),
  example.new('./example7.jsonnet'[2:], importstr './example7.jsonnet', import './example7.jsonnet')+example.withLink(),
  example.new('./pitfall1.jsonnet'[2:], importstr './pitfall1.jsonnet', import './pitfall1.jsonnet')+example.withLink(),
  example.new('./pitfall2.jsonnet'[2:], importstr './pitfall2.jsonnet', import './pitfall2.jsonnet')+example.withLink(),
  example.new('./pitfall3.jsonnet'[2:], importstr './pitfall3.jsonnet', import './pitfall3.jsonnet')+example.withLink(),
  example.new('./pitfall4.jsonnet'[2:], importstr './pitfall4.jsonnet', import './pitfall4.jsonnet')+example.withLink(),
]
