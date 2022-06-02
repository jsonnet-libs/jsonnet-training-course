# About

## Who is this?

I'm [Jeroen Op 't Eynde](http://simplistic.be), a software engineer at [Grafana
Labs](https://grafana.com) and a maintainer on [Tanka](https://tanka.dev) and the
[jsonnet-libs/k8s](https://github.com/jsonnet-libs/k8s) project.

This course is the result countless hours of researching and debating with [Malcolm
Holmes](https://github.com/malcolmholmes), [Tom Braack](https://shorez.de/) and many
colleagues and community members on how to maintain and write more effective Jsonnet.

## What are the lessons we've learned after using Jsonnet for years?

Grafana Labs uses a mixture of Terraform (HCL) and Jsonnet to configure the Cloud
infrastructure and applications on Kubernetes. While new hires are often familiar with
Terraform, they might never have heard of Jsonnet. This made that question the top voted
topic for training sessions by new hires at Grafana Labs.

While a training session can cover the basics or highlights in ~30min, there is much more
to it. We usually point out to the excellent tutorials on
[jsonnet.org](https://jsonnet.org/learning/tutorial.html) to get started, these explain
very well how Jsonnet works but not necessarily how to work with Jsonnet. This course
attempts to cover the idioms we've been adopting over years of discovering.

## Why did we pick Jsonnet?

With the acquisition of Kausal by Grafana Labs early 2018, we also adopted Ksonnet,
laying down the base for configuration management with Jsonnet. In addition to the
[language comparison](https://jsonnet.org/articles/comparisons.html) on jsonnet.org,
there are a few other advantages.

The most common tool to manage Kubernetes manifests today is Helm, so why not use that?
Helm chose some unhelpful approaches, by templating the YAML they only allow for one
level of abstraction (values.yaml), anything beyond that requires a change request
upstream or more commonly a fork. This causes a massive asymmetry between authoring and
using Helm charts.

Jsonnet on the other hand allows for an infinite number of abstractions, the initial
author only needs to worry about their use case, so libraries can be kept quite concise.
If a user wants to do something slightly different, they can simple concatenate the
change to the library.

> **Helm support in Tanka**
>
> Tanka has built-in [support for Helm charts](https://tanka.dev/helm#helm-support),
> giving the Jsonnet community access to the biggest ecosystem of application definitions
> for Kubernetes.

## What benefit do we gain from it?

Jsonnet is a language about data. By managing configuration with Jsonnet, it essentially
turns into a massive programmable database. The infinite number of abstractions allows to
create layers, a Deployment is part of an application, which can be included in a cell
that gets deployed to a cluster. By extending the cluster list, new cells can be created
and applications automatically become available without the need to configure and deploy
each application individually.

Each of these concepts has their own configuration attributes that could be managed by
a different team. This means that, with a clean, well defined API between layers of
abstraction, a developer new to Jsonnet needn't learn every layer, they only need to
learn the layer they are interested in, enabling them to become productive much faster
than if they had to code every layer.

