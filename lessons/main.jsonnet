local c = import 'coursonnet.libsonnet';
local page = c.page;

page.new(
  'index.md',
  'Jsonnet Training Materials',
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
//{
//  render+: {
//    'index.md'+:
//      |||
//        <style>
//        body { margin-right: 50% }
//
//        li.L0, li.L1, li.L2, li.L3,
//        li.L5, li.L6, li.L7, li.L8 {
//          list-style-type: decimal !important;
//        }
//        </style>
//        <script>
//        var pres = document.getElementsByTagName('pre');
//        for (i=0;i<pres.length; i++) {
//          pres[i].className='prettyprint linenums';
//        }
//        PR.prettyPrint();
//        </script>
//        <script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js"></script>
//      |||,
//  },
//}
