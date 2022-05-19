local c = import 'coursonnet.libsonnet';
local lesson = c.lesson;

local examples = import './examples.jsonnet';

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
    'Write an object-oriented library',
    'Properly use keywords such as `local`, `super`, `self`, `null` and `$`',
    'Write for extensibility with `::`, `+:` and objects rather than arrays',
    "Write object-oriented with 'mixin' functions",
    'Apply YAGNI often',
    |||
      Know how to avoid common pitfalls:
        - Builder pattern
        - `_config` and `_images` pattern
        - overuse of `$`
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
)
//{
//  page+: {
//    render+: {
//      'lesson1.md'+:
//        |||
//          <style>
//          body { margin-right: 50% }
//
//          li.L0, li.L1, li.L2, li.L3,
//          li.L5, li.L6, li.L7, li.L8 {
//            list-style-type: decimal !important;
//          }
//          </style>
//          <script>
//          var pres = document.getElementsByTagName('pre');
//          for (i=0;i<pres.length; i++) {
//            pres[i].className='prettyprint linenums';
//          }
//          PR.prettyPrint();
//          </script>
//          <script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js"></script>
//        |||,
//    },
//  },
//}
