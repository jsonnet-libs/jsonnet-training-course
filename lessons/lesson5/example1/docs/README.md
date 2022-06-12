# package webserver

`webserver` provides a basic webserver on Kubernetes

## Install

```
jb install github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1@master
```

## Usage

```jsonnet
local webserver = import "github.com/jsonnet-libs/jsonnet-training-course/lessons/lesson5/example1/example4.jsonnet"
```

## Index

* [`fn new(name, replicas=1)`](#fn-new)
* [`fn withImage(image)`](#fn-withimage)
* [`obj images`](#obj-images)

## Fields

### fn new

```ts
new(name, replicas=1)
```

`new` creates a Deployment object for Kubernetes

* `name` sets the name for the Deployment object
* `replicas` number of desired pods, defaults to 1


### fn withImage

```ts
withImage(image)
```

`withImage` modifies the image used for the httpd container

### obj images

`images` provides images for common webservers

Usage:

```
webserver.new('my-nginx')
+ webserver.withImage(webserver.images.nginx)
```


* `images.apache` (`string`): `"httpd:2.4"` - Apache HTTP webserver
* `images.nginx` (`string`): `"nginx:1.22"` - Nginx HTTP webserver
