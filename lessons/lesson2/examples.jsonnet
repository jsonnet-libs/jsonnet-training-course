local example = (import 'coursonnet.libsonnet').example;
[
  example.new(
    'example1.jsonnetfile.json',
    import './example1.jsonnetfile.json',
    importstr './example1.jsonnetfile.json',
    'json'
  ) + { render: self.code },

  example.new(
    'example2/jsonnetfile.json',
    import './example2/jsonnetfile.json',
    importstr './example2/jsonnetfile.json',
    'json'
  ) + { render: self.code },

  example.new(
    'example2/jsonnetfile.lock.json',
    import './example2/jsonnetfile.lock.json',
    importstr './example2/jsonnetfile.lock.json',
    'json'
  ) + { render: self.code },

  example.new(
    'example3/jsonnetfile.json',
    import './example3/jsonnetfile.json',
    importstr './example3/jsonnetfile.json',
    'json'
  ) + { render: self.code },

  example.new(
    'example3/.gitignore',
    {},
    importstr './example3/.gitignore',
    'json'
  ) + { render: self.code },

]
