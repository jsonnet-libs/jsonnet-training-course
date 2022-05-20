{
  local root = self,

  page: {
    new(filename, title, content): {
      local this = self,

      filename: filename,
      title: title,
      content: content,

      render: {
        [filename]: |||
          # %(title)s

          %(content)s
        ||| % this,
      },
    },

    withHTML():: {
      render+:
        |||
          <style>
          html {
            margin: 0;
            padding: 0;
            min-height: 100%;
            background: lightgrey;
          }
          body {
            margin: 0;
            padding: 1em;
            min-height: 100%;
            margin-left: 15%;
            margin-right: 15%;
            background: white;
            border: thin solid grey;
            border-top: 0;
          }
          blockquote {
            background: lightyellow;
            padding: .1em;
            padding-left: 1em;
            margin-left: 0;
            margin-right: 0;
            display: flow-root;
          }
          h1, h2, h3, h4, h5, h6, hr {
            clear: both;
          }
          hr {
            visibility: hidden;
          }
          ul {
            display: flow-root;
          }
          ul li code, p code {
            background: ghostwhite;
            padding: 0.2em;
          }
          pre {
            float: left;
            margin-top: 0;
            margin-right: 1em;
            width: 70ch;
            overflow-x: scroll;
          }

          li.L0, li.L1, li.L2, li.L3,
          li.L5, li.L6, li.L7, li.L8 {
            list-style-type: decimal !important;
          }
          </style>
          <script>
          var pres = document.getElementsByTagName('pre');
          for (i=0;i<pres.length; i++) {
            pres[i].className='prettyprint linenums';
          }
          PR.prettyPrint();
          </script>
          <script src="https://cdn.jsdelivr.net/gh/google/code-prettify@master/loader/run_prettify.js"></script>
        |||,
    },
  },

  lesson: {
    new(
      slug,
      title,
      summary,
      objectives,
      lesson,
      conclusion,
    ): {
      content: |||
        %(summary)s

        ## Objectives

        %(objectives)s

        ## Lesson

        %(lesson)s

        ## Conclusion

        %(conclusion)s
      ||| % {
        title: title,
        summary: summary,
        objectives:
          std.join('\n', [
            '- %s' % objective
            for objective in objectives
          ]),
        lesson: lesson,
        conclusion: conclusion,
      },

      page: root.page.new(
        slug + '.md',
        title,
        self.content,
      ),
    },
  },

  example: {
    new(filename, jsonnet, string, type='jsonnet'): {
      local this = self,

      filename: filename,
      jsonnet: jsonnet,
      string: string,
      type: type,
      base64: std.base64(self.string),
      playground: 'https://jsonnet-libs.github.io/playground/?code=%s' % self.base64,

      code:
        |||
          ```%(type)s
          %(string)s
          // %(filename)s
          ```
        ||| % self,

      iframe: '<iframe src="%s" width="100%%" height="500px"></iframe>' % self.playground,

      withLink():: '<small>[Try `%(filename)s` in Jsonnet Playground](%(playground)s)</small>' % self,

      withFoldedIframe()::
        |||
          <details>
            <summary><small>Try in Jsonnet Playground</small></summary>
            %(iframe)s
          </details>
        ||| % self,

      render:
        self.code
        + self.withLink(),
    },
  },
}
