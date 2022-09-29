local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson3',
  'Refactoring exercise',
  |||
    In the first lesson we've written a extensible library and in the second lesson we've
    covered package management with jsonnet-bundler. In this lesson we'll combine what
    we've learned and rewrite that library.
  |||,
  [
    'Rewrite a library',
    'Vendor and use `k8s-libsonnet`',
    'Understand the `lib/k.libsonnet` convention',
  ],
  (importstr './lesson.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  |||
    This exercise showed how to make a library more succinct and readable. By using the
    `k.libsonnet` abstract, the user has the option to use an alternative version of the
    `k8s-libsonnet` library.
  |||,
)
