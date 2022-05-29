local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson4',
  'Further developing libraries',
  |||
    When starting out with Jsonnet, it is very likely that you'll with existing code and
    dependencies. Developing on these can seem confusing and tedious, however there are
    several techniques that can help us iterate at different velocities.
  |||,
  [
    'Wrap and extend a dependency locally',
    'Developing on upstream libraries',
  ],
  (importstr './lesson.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  |||
    Wrapping libraries locally by leveraging the extensible nature of Jsonnet can be very
    useful. It can alter default behavior that is more suitable for the project.

    Developing directly on vendored libraries on the other hand is quite clumsy, the
    techniques described require a bit of pragmatism to be useful. jsonnet-bundler could
    benefit from a feature to make this easier.
  |||,
)
