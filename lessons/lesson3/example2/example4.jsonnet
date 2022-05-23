local webserver = import 'webserver/main.libsonnet';

webserver.new('wonderful-webserver')
+ webserver.withImage('httpd:2.5')
