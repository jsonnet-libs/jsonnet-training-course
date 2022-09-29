local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

lesson.new(
  'lesson2',
  'Package management',
  |||
    There are a ton of Jsonnet libraries out there, ranging from big generated libraries
    to manually curated for a very specific purpose. Let's have a look at how to find and
    vendor them.
  |||,
  [
    'Find libraries',
    'Install and update with jsonnet-bundler',
    'Import a library on the `JSONNET_PATH`',
    'Handle common use cases',
  ],
  (importstr './lesson.md') %
  std.foldr(
    function(e, acc)
      acc { [e.filename]: e.render },
    examples,
    {}
  ),
  |||
    Finding libraries and package managemet can be cumbersome, nonetheless
    jsonnet-bundler makes it a bit easier to work with the distributed ecosystem.
    Additionally `JSONNET_PATH` offers a level of flexibility to work around the package
    management shortcomming.
  |||,
)
