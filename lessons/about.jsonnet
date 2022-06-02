local c = import 'coursonnet.libsonnet';
local page = c.page;

page.new(
  'about.md',
  'About',
  (importstr './about.md'),
)
