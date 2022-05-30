## TODO notes

Answer questions tl;dr, make reference to longer descriptions

Why?

- Why jsonnet? What benefit do we gain from it?
- Why is it worth the inconvenience of people having to learn a new language/paradigm?
- Why we use jsonnet (vs other solutions/tools)?
- Consider creating an extensive retrospective design doc/blog post

How? (kind of covered in index page and subsequent lessons)

- What are the lessons we’ve learned after using jsonnet for years?
- What are some GrafanaLabs jsonnet idioms that we try to use?
- Tools/tricks when writing/debugging jsonnet?

ref: [internal brainstorm doc](https://docs.google.com/document/d/1zDFaASBuDdsuxEXXc1E1UGhsYvWnYqc3m8QBNzM9hTU/edit#)

Ideas:
- Consider Jsonnet introduction lesson
- [IDE configuration](https://docs.google.com/spreadsheets/d/10pTqNvOC-0pDhgP3dYwjM6ywWVEyO0wnfl__ewfQa2Y/edit), guest lessons/breakouts (vim, emacs, neovim, VSCode,  IntelliJ)
- Consider Terminology list
- Provide good-read list
- CD process (kube-manifests, jsonnet-libs/k8s github workflow)

Lessons:

- Write a reusable library
    - Properly use keywords such as `self`, `$`, `local`, `super`, `null`
    - Write for extensibility with `::` and objects rather than arrays
    - Write object-oriented with 'mixin' functions
    - Apply YAGNI often
    - Know how to avoid common pitfalls:
        - Builder pattern
        - "private" variables

- Don't write libraries
    - Find existing libraries
    - Vendor libraries with `jsonnet-bundler`
    - Use a vendored library with `JSONNET_PATH`

- Exercise: rewrite reusable library with `k8s-libsonnet`
    - Vendoring `k8s-libsonnet` with `jsonnet-bundler`
    - Understand `k.libsonnet` convention
    - Use generated documentation

- Developing libraries
    - Wrapping libraries
      - Pentagon usecase
      - Grafonnet usecase
    - Developing with upstream libraries

- Documentation & testing
    - Use of `docsonnet`
    - Test with the use of `error`, `null` and `prune`
    - Investigate testing framework (`jsonnetunit` seems dead, fork?)

- Jsonnet use cases
    - Roll out in 'waves' (dev/stag/prod)
    - Come up with a few examples (Grafonnet, Github Actions)
    - Write YAML/JSON files (Grafonnet, Github Actions)
    - Generate new libraries from specifications (again)

- Jsonnet features/pitfalls
    - `prune` is recursive
    - Provide deprecation notices with `std.trace`
    - Handle dynamic inputs with top-level arguments and `/dev/stdin`
    - Write arbitrary files (jsonnet -S -m)

Already covered by tanka.dev:

- Using Tanka
    - Use of inline environments (hint: `tanka-util`)
    - Keep environments clean
    - Locally inspect with `tk eval` 
    - Continuous Delivery with `tk export`
    - Know how to avoid common pitfalls:
        - Global variables
        - Smashing libraries together

- Exercise: Use Helm chart in Jsonnet
    - Vendor Helm charts with `tk tool charts`
    - Load chart with `tanka-util`
    - Modify chart beyond `values.yaml`
    - Patch arrays

