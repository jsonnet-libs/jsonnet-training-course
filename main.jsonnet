(import 'lessons/main.jsonnet').render
+ std.foldr(
  function(l, acc)
    acc {
      [l.page.filename]: l.page.render[l.page.filename],
    }
  ,
  import 'lessons/lessons.jsonnet',
  {},
)
