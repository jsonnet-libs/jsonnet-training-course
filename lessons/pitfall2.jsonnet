local configMap(name, content) = {
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: name,
  },
  data: {
    'filename.txt': content,
  },
};

{
  configmaps: std.prune([
    configMap('file1', 'this is my content'),
    configMap('file2', ''),  // intentionally left empty
  ]),

}
