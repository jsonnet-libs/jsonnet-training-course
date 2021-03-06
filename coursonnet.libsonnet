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

      slug: slug,
      title: title,
      filename: self.page.filename,
      render: self.page.render[self.filename],

      page: root.page.new(
        slug + '.md',
        title,
        self.content,
      ),
    },
  },

  example: {
    new(filename, string, jsonnet={}, type='jsonnet'): {
      local this = self,

      filename: filename,
      string: string,
      jsonnet: jsonnet,
      type: type,
      base64: std.base64(self.string),
      playground: 'https://jsonnet-libs.github.io/playground/?code=%s' % self.base64,

      code:
        |||
          ~~~%(type)s
          %(string)s
          // %(filename)s
          ~~~
        ||| % self,

      render: self.code,
    },

    withLink():: {
      render+:
        '<small>[Try `%(filename)s` in Jsonnet Playground](%(playground)s)</small>' % self,
    },

    withFoldedIframe():: {
      iframe: '<iframe src="%s" width="100%%" height="500px"></iframe>' % self.playground,

      render+:
        |||
          <details>
            <summary><small>Try in Jsonnet Playground</small></summary>
            %(iframe)s
          </details>
        ||| % self,
    },

  },
}
