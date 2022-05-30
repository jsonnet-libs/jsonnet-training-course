# Jsonnet Training Course

## What are the lessons we've learned after using jsonnet for years?

Grafana Labs uses a mixture of Terraform (HCL) and Jsonnet to configure the Cloud
infrastructure and applications on Kubernetes. While new hires are often familiar with
Terraform, they might never have heard of Jsonnet. This made that question the top voted
topic for training sessions by new hires at Grafana Labs.

While a training session can cover the basics or highlights in ~30min, there is much more
to it. We usually point out to the excellent tutorials on
[jsonnet.org](https://jsonnet.org/learning/tutorial.html) to get started, this explains
very well how Jsonnet works but not necessarily how to work with Jsonnet. This course
attempts to cover the idioms we've been adopting over years of discovering.

The examples and use cases in this course are from real world usage instead of working
with arbitrary examples like cocktails or your favorite pets. The step by step examples
show how to use Jsonnet effectively, at the same time explaining the why, covering
pitfalls and other hurdles we might have come across.

This course is a work in progress, the plan is to dive deeper into the Jsonnet ecosystem
with more lessons, exercises and use cases. If you notice a mistake or want to share your
experience, reach out to us on [TODO: link to github repo]().

## Getting started

Jsonnet has two implementations (C++ and Go), the examples should work with either version
above v0.18.0. If you don't know what to choose then [install the Go
implementation](https://github.com/google/go-jsonnet#installation-instructions).

For package management we'll use jsonnet-bundler, please
[install](https://github.com/jsonnet-bundler/jsonnet-bundler#install) this too.

## Lessons

> Note: A lot of the examples will be around Kubernetes objects, but no worries if you
> don't know how Kubernetes works, this isn't a requirement for understanding the Jsonnet
> examples.

1. [Write an extensible library](lesson1.md)
1. [Understanding Package management](lesson2.md)
1. [Exercise: rewrite a library with `k8s-libsonnet`](lesson3.md)
1. [Further developing libraries](lesson4.md)


