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
  'Providing documentation with Docsonnet',
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
    Providing documentation can be very helpful to communicate the library's intended
    use. The argument types give an indication about the expected values and the help
    text can contain code samples to get meaningful results quickly.

    Rendering documentation can be done directly with Jsonnet without additional
    programs, altough the incantations may feel like magic at first.
  |||,
)
