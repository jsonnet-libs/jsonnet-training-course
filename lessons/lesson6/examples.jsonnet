local example = (import 'coursonnet.libsonnet').example;
[
  example.new('./example1/example1.jsonnet'[2:], importstr './example1/example1.jsonnet', import './example1/example1.jsonnet'),
  example.new('./example1/example2.jsonnet'[2:], importstr './example1/example2.jsonnet', import './example1/example2.jsonnet'),
  example.new('./example1/example3.jsonnet'[2:], importstr './example1/example3.jsonnet', import './example1/example3.jsonnet'),
  example.new('./example1/example4.jsonnet'[2:], importstr './example1/example4.jsonnet', import './example1/example4.jsonnet'),
  example.new('./example1/example5.jsonnet'[2:], importstr './example1/example5.jsonnet', import './example1/example5.jsonnet'),
  example.new('./example1/example6.jsonnet'[2:], importstr './example1/example6.jsonnet', import './example1/example6.jsonnet'),
  example.new('./example1/example7.jsonnet'[2:], importstr './example1/example7.jsonnet', import './example1/example7.jsonnet'),
  example.new('./example1/pitfall1.jsonnet'[2:], importstr './example1/pitfall1.jsonnet', import './example1/pitfall1.jsonnet'),
  example.new('./example1/pitfall2.jsonnet'[2:], importstr './example1/pitfall2.jsonnet', import './example1/pitfall2.jsonnet'),
  example.new('./example1/lib/webserver/correct.libsonnet'[2:], importstr './example1/lib/webserver/correct.libsonnet', import './example1/lib/webserver/correct.libsonnet'),
  example.new('./example1/lib/webserver/main.libsonnet'[2:], importstr './example1/lib/webserver/main.libsonnet', import './example1/lib/webserver/main.libsonnet'),
  example.new('./example1/lib/webserver/wrong1.libsonnet'[2:], importstr './example1/lib/webserver/wrong1.libsonnet', import './example1/lib/webserver/wrong1.libsonnet'),
  example.new('./example1/lib/webserver/wrong2.libsonnet'[2:], importstr './example1/lib/webserver/wrong2.libsonnet', import './example1/lib/webserver/wrong2.libsonnet'),
  example.new('./example1/lib/webserver/wrong3.libsonnet'[2:], importstr './example1/lib/webserver/wrong3.libsonnet', import './example1/lib/webserver/wrong3.libsonnet'),
  example.new('./example1/example1.jsonnet.output'[2:], importstr './example1/example1.jsonnet.output', {filename:'./example1/example1.jsonnet.output'}),
  example.new('./example1/example2.jsonnet.output'[2:], importstr './example1/example2.jsonnet.output', {filename:'./example1/example2.jsonnet.output'}),
  example.new('./example1/example3.jsonnet.output'[2:], importstr './example1/example3.jsonnet.output', {filename:'./example1/example3.jsonnet.output'}),
  example.new('./example1/example4.jsonnet.output'[2:], importstr './example1/example4.jsonnet.output', {filename:'./example1/example4.jsonnet.output'}),
  example.new('./example1/example5.jsonnet.output'[2:], importstr './example1/example5.jsonnet.output', {filename:'./example1/example5.jsonnet.output'}),
  example.new('./example1/example6.jsonnet.output'[2:], importstr './example1/example6.jsonnet.output', {filename:'./example1/example6.jsonnet.output'}),
  example.new('./example1/example7.jsonnet.output'[2:], importstr './example1/example7.jsonnet.output', {filename:'./example1/example7.jsonnet.output'}),
  example.new('./example1/pitfall1.jsonnet.output'[2:], importstr './example1/pitfall1.jsonnet.output', {filename:'./example1/pitfall1.jsonnet.output'}),
  example.new('./example1/pitfall2.jsonnet.output'[2:], importstr './example1/pitfall2.jsonnet.output', {filename:'./example1/pitfall2.jsonnet.output'}),
]
