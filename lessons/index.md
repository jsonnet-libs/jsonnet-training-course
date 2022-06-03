Excited as you might be after following the excellent tutorials on
[jsonnet.org](https://jsonnet.org/learning/tutorial.html), it can still be daunting to
actually use Jsonnet in the real world. This hands-on course attempts to cover common
Jsonnet idioms that have been battle tested over several years.

The examples and use cases in this course are from real world usage instead of working
with arbitrary examples like cocktails or your favorite pets. The step by step examples
show how to use Jsonnet effectively, at the same time explaining the why, covering
pitfalls and other hurdles we might come across.

This course is a work in progress, the plan is to dive deeper into the Jsonnet ecosystem
with more lessons, exercises and use cases. If you notice a mistake or want to share your
experience, reach out to us on
[Github](https://github.com/jsonnet-libs/jsonnet-training-course).

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

%(lessons)s
