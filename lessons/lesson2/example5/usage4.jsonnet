local istiolib = import 'istiolib.libsonnet';

istiolib.networking.v1beta1.virtualService.new('test')
