local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples =
  (import './examples.jsonnet')
  + [
    c.example.new('example1/Makefile', importstr './example1/Makefile', {}, 'makefile'),
    c.example.new('example1/docs/README.md', importstr './example1/docs/README.md', {}, 'markdown'),
  ];

lesson.new(
  'lesson5',
  'Documentation',
  |||
    In most programming languages documentation is done with the use of docstrings in
    comments. However that is not possible with Jsonnet right now. To work around this, we
    can use [Docsonnet](https://github.com/jsonnet-libs/docsonnet) and provide docstrings
    as Jsonnet code.
  |||,
  [
    'Write docstrings for Docsonnet',
    'Generate markdown documentation',
  ],
  (importstr './lesson.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  |||
    TODO
  |||,
)
