local c = import 'coursonnet.libsonnet';
local pages = import 'lessons/lessons.jsonnet';

function(nav=false)
  (import 'lessons/main.jsonnet').render
  + {
    [pages[i].filename]:
      if nav
      then
        (
          if i > 0
          then '[[prev](%s.html)]' % pages[i - 1].slug
          else ''
        )
        + '[[index](index.html)]'
        + (
          if i < (std.length(pages) - 1)
          then '[[next](%s.html)]' % pages[i + 1].slug
          else ''
        )
        + '\n'
        + pages[i].render
        + (
          if i > 0
          then '[[prev](%s.html)]' % pages[i - 1].slug
          else ''
        )
        + '[[index](index.html)]'
        + (
          if i < (std.length(pages) - 1)
          then '[[next](%s.html)]' % pages[i + 1].slug
          else ''
        )
      else
        pages[i].render
    for i in std.range(0, std.length(pages) - 1)

  }
