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
            /* sans-serif fonts are generally better readable for people with dyslexia */
            font-family: sans-serif;
            font-size: 1.15rem;
          }
          blockquote {
            background: lightyellow;
            padding: .1em;
            padding-left: 1em;
            margin-left: 0;
            margin-right: 0;
            display: flow-root;
          }
          p {
            display: flow-root;
            line-height: 1.5em;
          }
          h1 a, h2 a, h3 a,
          h4 a, h5 a, h6 a {
              text-decoration: none;
              color: black;
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
          ol li,
          ul li {
            line-height: 1.5em;
          }
          ul li code, p code {
            background: ghostwhite;
            padding: 0.2em;
          }
          pre {
            float: left;
            margin-top: 0;
            margin-right: 1em;
            width: min(50%, 70ch);
            overflow-x: scroll;
          }

          @media only screen and (max-width: 720px) {
            body {
              width: auto;
              margin-left: 0;
              margin-right: 0;
              border: 0;
            }
            pre {
              clear: both;
              float: none;
              width: min(95%, 70ch);
            }
          }

          li.L0, li.L1, li.L2, li.L3,
          li.L5, li.L6, li.L7, li.L8 {
            list-style-type: decimal !important;
            line-height: normal;
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
