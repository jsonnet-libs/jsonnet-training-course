local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson1',
  'Write an extensible library',
  |||
    Jsonnet gives us a lot of freedom to organize our libraries, there is no right or
    wrong, however a well-organized library can get you a long way. While applying common
    software development best-practices, we'll come up with an extensible library to
    deploy a webserver on Kubernetes.
  |||,
  [
    "Write object-oriented with 'mixin' functions",
    'Develop for extensibility with `::`, `+:` and objects rather than arrays',
    'Properly use keywords such as `local`, `super`, `self`, `null` and `$`',
    'Know how to avoid common pitfalls',
  ],
  (importstr './lesson.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  |||
    By following an object-oriented approach, it is possible to build extensible jsonnet
    libraries. They can be extended infinitely and in such a way that it doesn't impact
    existing uses, providing backwards compatibility.

    The pitfalls show a few patterns that exist in the wild but should be avoided and
    refactored as they become unsustainable in the long term.
  |||,
)
