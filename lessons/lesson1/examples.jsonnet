local example = (import 'coursonnet.libsonnet').example;
[
  example.new('./example1.jsonnet'[2:], import './example1.jsonnet', importstr './example1.jsonnet'),
  example.new('./example2.jsonnet'[2:], import './example2.jsonnet', importstr './example2.jsonnet'),
  example.new('./example3.jsonnet'[2:], import './example3.jsonnet', importstr './example3.jsonnet'),
  example.new('./example4.jsonnet'[2:], import './example4.jsonnet', importstr './example4.jsonnet'),
  example.new('./example5.jsonnet'[2:], import './example5.jsonnet', importstr './example5.jsonnet'),
  example.new('./example6.jsonnet'[2:], import './example6.jsonnet', importstr './example6.jsonnet'),
  example.new('./example7.jsonnet'[2:], import './example7.jsonnet', importstr './example7.jsonnet'),
  example.new('./pitfall1.jsonnet'[2:], import './pitfall1.jsonnet', importstr './pitfall1.jsonnet'),
  example.new('./pitfall2.jsonnet'[2:], import './pitfall2.jsonnet', importstr './pitfall2.jsonnet'),
  example.new('./pitfall3.jsonnet'[2:], import './pitfall3.jsonnet', importstr './pitfall3.jsonnet'),
  example.new('./pitfall4.jsonnet'[2:], import './pitfall4.jsonnet', importstr './pitfall4.jsonnet'),
]
