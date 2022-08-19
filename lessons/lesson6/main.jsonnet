local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson6',
  'Unit testing',
  |||
    Performing maintenance on an existing library can be quite a task, the initial
    intention might not always be obvious. Adding a few unit tests can make a big
    difference years down the line.
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
    Writing unit tests can feel like a burden, but when done right they can be elegant
    and quite cheap to write.

    And remember: "A society grows great when old men plant trees whose shade they know
    they shall never sit in."
  |||,
)
