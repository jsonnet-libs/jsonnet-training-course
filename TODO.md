## TODO notes

ref: [brainstorm doc](https://docs.google.com/document/d/1zDFaASBuDdsuxEXXc1E1UGhsYvWnYqc3m8QBNzM9hTU/edit#)

TODO:
- Consider Jsonnet introduction lesson
- Structure of the 'lessons' (Intro, Goals, Content, Conclusion)
- IDE configuration, guest lessons/breakouts (vim, emacs, neovim, VSCode,  IntelliJ)
- Consider Terminology list
- Provide good-read list
- CD/Kube-manifests

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

- Developing libraries
    - Wrapping libraries
      - Pentagon usecase
      - Grafonnet usecase
    - Developing with upstream libraries

It often happens that a vendored library is developed alongside the environment that is
using it. However `jb install` will reset the contents of edits in `vendor/`, so that is
not an ideal location to develop a library.

TODO: several options here, not sure which is most useful

- Simply edit in `vendor/`, copy over the contents to the local path, risk of `jb install`
    removing the changes.
- Git clone/checkout/submodule in `vendor/`, same risk of `jb install` removing the
    changes.
- Change jsonnetfile.json to use file://path/to/local/library
- Depend on import order and symlink/develop in `lib/`, taking precedence over `vendor/`.

> Idea: perhaps jsonnet-bundler could benefit from an --editable feature like `pip`.

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


