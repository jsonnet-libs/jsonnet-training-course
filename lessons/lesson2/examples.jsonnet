local example = (import 'coursonnet.libsonnet').example;

[
  example.new(
    'example1/jsonnetfile.json',
    importstr './example1/jsonnetfile.json',
    type='json'
  ),

  example.new(
    'example2/jsonnetfile.json',
    importstr './example2/jsonnetfile.json',
    type='json'
  ),

  example.new(
    'example2/jsonnetfile.lock.json',
    importstr './example2/jsonnetfile.lock.json',
    type='json'
  ),

  example.new(
    'example3/jsonnetfile.json',
    importstr './example3/jsonnetfile.json',
    type='json'
  ),

  example.new(
    'example3/.gitignore',
    importstr './example3/.gitignore',
    type='gitignore'
  ),

  example.new(
    'example4/jsonnetfile.json',
    importstr './example4/jsonnetfile.json',
    type='json'
  ),

  example.new(
    'example5/usage1.jsonnet',
    importstr './example5/usage1.jsonnet',
  ),

  example.new(
    'example5/usage2.jsonnet',
    importstr './example5/usage2.jsonnet',
  ),

  example.new(
    'example5/usage3.jsonnet',
    importstr './example5/usage3.jsonnet',
  ),

  example.new(
    'example5/usage4.jsonnet',
    importstr './example5/usage4.jsonnet',
  ),

  example.new(
    'example5/lib/istiolib.libsonnet',
    importstr './example5/lib/istiolib.libsonnet',
  ),
]
