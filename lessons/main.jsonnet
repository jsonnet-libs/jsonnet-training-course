local c = import 'coursonnet.libsonnet';
local page = c.page;

page.new(
  'index.md',
  'Jsonnet Training Course',
  (importstr './index.md') % {
    lessons: std.foldl(
      function(acc, l)
        acc +
        '1. [%(title)s](%(filename)s)\n' % l.page
      ,
      import './lessons.jsonnet',
      '',
    ),
  }
  ,
)
