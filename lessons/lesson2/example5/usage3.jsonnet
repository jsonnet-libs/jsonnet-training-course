local istiolib = import 'istio-lib/main.libsonnet';

istiolib.networking.v1beta1.virtualService.new('test')
