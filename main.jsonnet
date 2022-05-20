local c = import 'coursonnet.libsonnet';
local pages =
  (import 'lessons/main.jsonnet').render
  + std.foldr(
    function(l, acc)
      acc {
        [l.page.filename]: l.page.render[l.page.filename],
      }
    ,
    import 'lessons/lessons.jsonnet',
    {},
  );

function(html=false) {
  [p]:
    if html then
      '[[index](index.html)]\n'
      + pages[p]
      + c.page.withHTML().render
    else pages[p]
  for p in std.objectFields(pages)
}
