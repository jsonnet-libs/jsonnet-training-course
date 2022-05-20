local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson3',
  "Don't write libraries",
  |||
    There are a ton of Jsonnet libraries out there, ranging from big generated libraries
    to manually curated for a very specific purpose. Let's have a look at how to find and
    vendor them.
  |||,
  [
    'Find existing libraries',
    'Vendor libraries with `jsonnet-bundler`',
    'Use a vendored library with `JSONNET_PATH`',
    'Develop on a vendored library',
    'Generate new libraries from specifications',
  ],
  (importstr './lesson.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  'TODO',
)
