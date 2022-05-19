# Jsonnet Training materials

Exciting as you might be after following the [excellent jsonnet.org tutorial](https://jsonnet.org/learning/tutorial.html),
it can still be daunting to actually use Jsonnet in the real world. Instead of working
with arbitrary examples like cocktails or your favorite pets, these training materials
contain real worlds examples (good and bad) in the hope to lower the bar of entry.

TODO:
- Consider Jsonnet introduction lesson
- Structure of the 'lessons' (Intro, Goals, Content, Conclusion)
- IDE configuration, guest lessons/breakouts (vim, emacs, neovim, VSCode,  IntelliJ)
- Consider Terminology list
- Provide good-read list
- CD/Kube-manifests

Common questions:

What are the lessons we’ve learned after using jsonnet for years?
Why jsonnet? What benefit do we gain from it?
Why is it worth the inconvenience of people having to learn a new language/paradigm?
Why we use jsonnet (vs other solutions/tools)?
Tools/tricks when writing/debugging jsonnet?
What are some GrafanaLabs jsonnet idioms that we try to use?

ref: https://docs.google.com/document/d/1zDFaASBuDdsuxEXXc1E1UGhsYvWnYqc3m8QBNzM9hTU/edit#


Lessons:

- Write a reusable library
    - Goals:
        - Properly use keywords such as `self`, `$`, `local`, `super`, `null`
        - Write for extensibility with `::` and objects rather than arrays
        - Write object-oriented with 'mixin' functions
        - Apply YAGNI often
        - Know how to avoid common pitfalls:
            - Builder pattern
            - "private" variables
            - `prune` is recursive

- Don't write libraries
    - Goals:
        - Find existing libraries
        - Vendor libraries with `jsonnet-bundler`
        - Use a vendored library with `JSONNET_PATH`
        - Generate new libraries from specifications

- Exercise: rewrite reusable library with `k8s-libsonnet`
    - Goals:
        - Vendoring `k8s-libsonnet` with `jsonnet-bundler`
        - Understand `k.libsonnet` convention
        - Use generated documentation

- Using Tanka
    - Goals:
        - Use of inline environments (hint: `tanka-util`)
        - Keep environments clean
        - Locally inspect with `tk eval` 
        - Continuous Delivery with `tk export`
        - Know how to avoid common pitfalls:
            - Global variables
            - Smashing libraries together

- Exercise: Use Helm chart in Jsonnet
    - Goals:
        - Vendor Helm charts with `tk tool charts`
        - Load chart with `tanka-util`
        - Modify chart beyond `values.yaml`
        - Patch arrays

- Documentation & testing
    - Goals:
        - Use of `docsonnet`
        - Test with the use of `null` and `prune`
        - TODO: investigate testing framework `jsonnetunit` (seems dead, fork?)

- Powerful Jsonnet patterns
    - Goals:
        - Refactor libraries gradually (pentagon/eso example)
        - Roll out in 'waves' (dev/stag/prod)
        - Provide deprecation notices with `std.trace`

- Use Jsonnet everywhere
    - Goals:
        - TODO: come up with a few examples (Grafonnet, Github Actions)
        - Write YAML/JSON files (Grafonnet, Github Actions)
        - Write arbitrary files 
        - Handle dynamic inputs with top-level arguments and `/dev/stdin`
        - Generate new libraries from specifications (again)
