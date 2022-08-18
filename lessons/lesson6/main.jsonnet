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
    'Basic usage',
    'Advanced usage',
    'Pitfalls',
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
