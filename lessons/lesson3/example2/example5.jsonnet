local webserver = import 'webserver/main.libsonnet';

{
  webserver1:
    webserver.new('wonderful-webserver')
    + webserver.withImage('httpd:2.3'),

  webserver2:
    webserver.new('marvellous-webserver'),

  webserver3:
    webserver.new('incredible-webserver', 2),
}
