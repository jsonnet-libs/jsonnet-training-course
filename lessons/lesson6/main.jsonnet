local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson6',
  'Unit testing',
  |||
    TODO
  |||,
  [
    'Write unit tests in Jsonnet',
    'Do test-driven development',
    'Know how to avoid pitfalls',
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
