local c = import 'coursonnet.libsonnet';
local pages = import 'lessons/lessons.jsonnet';

local navMixin = function(pages, i)
  (
    if i > 0
    then '<span class="nav previous">[&laquo; previous](%s.html)</span> ' % pages[i - 1].slug
    else ''
  )
  + '<span class="nav index">[index](index.html)</span>'
  + (
    if i < (std.length(pages) - 1)
    then ' <span class="nav next">[next &raquo;](%s.html)</span>' % pages[i + 1].slug
    else ''
  )
  + '\n';

function(nav=false)
  (import 'lessons/main.jsonnet').render
  + {
    [pages[i].filename]:
      if nav
      then
        navMixin(pages, i)
        + pages[i].render
        + navMixin(pages, i)
      else
        pages[i].render
    for i in std.range(0, std.length(pages) - 1)

  }
