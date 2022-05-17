local c = import '../coursonnet.libsonnet';
local lesson = c.lesson;
local example = c.example;

local examples = [
  example.new(
    'example1.jsonnet',
    import './example1.jsonnet',
    importstr './example1.jsonnet',
  ),
  example.new(
    'example2.jsonnet',
    import './example2.jsonnet',
    importstr './example2.jsonnet',
  ),
  example.new(
    'example3.jsonnet',
    import './example3.jsonnet',
    importstr './example3.jsonnet',
  ),
  example.new(
    'example4.jsonnet',
    import './example4.jsonnet',
    importstr './example4.jsonnet',
  ),
  example.new(
    'example5.jsonnet',
    import './example5.jsonnet',
    importstr './example5.jsonnet',
  ),
  example.new(
    'example6.jsonnet',
    import './example6.jsonnet',
    importstr './example6.jsonnet',
  ),
  example.new(
    'pitfall1.jsonnet',
    import './pitfall1.jsonnet',
    importstr './pitfall1.jsonnet',
  ),
];

lesson.new(
  'lesson1',
  'Write a reusable library',
  |||
    Jsonnet gives us a lot of freedom to organize our libraries, there is no right or
    wrong, however a well-organized library can get you a long way. While applying common
    software development best-practices, we'll come up with an extensible library to
    deploy a web page on Kubernetes.
  |||,
  [
    'Properly use keywords such as `local`, `super`, `self`, `$` and `null`',
    'Write for extensibility with `::`, `+:` and objects rather than arrays',
    "Write object-oriented with 'mixin' functions",
    'Apply YAGNI often',
    |||
      Know how to avoid common pitfalls:
        - Builder pattern
        - "private" variables
        - `prune` is recursive
    |||,
  ],
  (importstr './lesson1.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  '',
).page.render
