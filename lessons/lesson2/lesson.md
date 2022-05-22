The ecosystem for Jsonnet libraries has organically grown and is quite distributed, there
is no central entity in control. Even though this gives the authors a great deal of
autonomy, it makes it harder to find libraries. The majority of libraries can be found in
Git repositories and are wholeheartedly open source.

- Github Topic [`jsonnet-lib`](https://github.com/topics/jsonnet-lib) lists the libraries
    that are tagged with `jsonnet-lib`. Cultivating this tag is encouraged.
- In the observability space, there is a sub-ecosystem of "mixins". The [Monitoring
    Mixins project](https://monitoring.mixins.dev/) is an effort to centralize them.
- Keyword search on Github:
    - [`jsonnet-libs`](https://github.com/search?q=jsonnet-libs)
        Organisations often share their libraries in such a repository.
    - [`libsonnet`](https://github.com/search?q=libsonnet)
        Libraries are often suffixed with `-libsonnet`
- Some applications offer jsonnet libraries to deploy, configure and/or monitor their
    application, look for a `jsonnetfile.json` in their repository.
- A few community members maintain an 'awesome list':
    - https://github.com/MacroPower/awesome-jsonnet
    - https://github.com/metalmatze/awesome-jsonnet
    - https://github.com/sh0rez/awesome-libsonnet

---

### <a id="jsonnet-bundler" href="#jsonnet-bundler">jsonnet-bundler</a>

Now that we can find libraries, we need a way to "install" them. Jsonnet libraries are
distributed as source code,  makes it quite simple process.

The [jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler/) project is
the de facto package manager for Jsonnet. It vendors libraries from Git repositories and
tracks them in `jsonnetfile.json`and its corresponding lockfile `jsonnetfile.lock.json`.

To get started, initialize the directory with the `jb init`:

%(example1/jsonnetfile.json)s

`jb init` creates a virtually empty `jsonnetfile.json`.

Originally `jb` vendored libraries as `vendor/<name>`, in large code bases this can cause
naming conflicts. To resolve this, `jb` started vendoring on the full repository path
`github.com/<org>/<repo>/<path/to/lib>/name`. However many libraries have references to
the short path, for that `"legacyImports": true` tells `jb` to also create a symlink to
this full path on short path `vendor/<name>` to keep this working.

Let's vendor a library:

`$ jb install github.com/jsonnet-libs/xtd`

> For this example we use [`xtd`](https://github.com/jsonnet-libs/xtd), it is a simple
> helper library with a collection of useful functions.

%(example2/jsonnetfile.json)s

`jsonnetfile.json` has a new entry in the `dependency` key, it refers to the source on
Github and defaults to the `master` branch for tracking its `version`.

When updating libraries, it will follow the `version` tag, for example `jb update
github.com/jsonnet-libs/xtd` will pull in the git commit that `master` refers to.

---

%(example2/jsonnetfile.lock.json)s

A new file `jsonnetfile.lock.json` is created, this contains the actual `version` that
should be installed, as this is a Git source it refers to a Git hash. Additionally it also
tracks a checksum value in `sum`.

With the lock file in place, calling `jb install` without param

---

```
.
├── jsonnetfile.json
├── jsonnetfile.lock.json
└── vendor
    ├── github.com
    │   └── jsonnet-libs
    │       └── xtd
    │           ├── ascii.libsonnet
    │           ├── camelcase.libsonnet
    │           ├── docs/
    │           ├── inspect.libsonnet
    │           ├── LICENSE
    │           ├── main.libsonnet
    │           ├── Makefile
    │           ├── README.md
    │           ├── test.jsonnet
    │           └── url.libsonnet
    └── xtd -> github.com/jsonnet-libs/xtd
```

The library is vendored into `vendor/github.com/jsonnet-libs/xtd` and a symlink on
`vendor/xtd` was added. The `vendor/` directory is a widespread convention, tools like
Tanka look here for imports.

%(example3/.gitignore)s

When shipping a library, generally only `jsonnetfile.json` is included. This way when
calling `jb install` on a library, it will pull whatever value is set in `version`. If
that is `master`, it will match the latest git commit.

It is often not necessary and even undesirable to distribute `jsonnetfile.lock.json` and
`vendor/` with a library, the `version` tag in `jsonnetfile.json` can be leveraged in case
a specific version is expected (for example when newer versions of dependencies have
breaking changes).

Add `jsonnetfile.lock.json` and `vendor/` to the `.gitignore` file so they are not
accidentally committed

---

_But what if `master` has a breaking change? Shouldn't the lock file be there to ensure
a specific version is installed?_

Although it is uncommon that things break often (based on empirical data), it is possible
to pin to a specific version of a dependency.

`$ jb install github.com/jsonnet-libs/xtd@803739029925cf31b0e3c6db2f4aae09b0378a6e`

%(example3/jsonnetfile.json)s

This will set `version` in `jsonnetfile.json` to ensure downstream users install the
dependency that works with the library.

`jb` defaults to the `master` tag, new Github repos default to the `main` tag. To override
this, add `@main`:

`$ jb install github.com/jsonnet-libs/xtd@main`

Alternatively it is possible to pin to a certain tag:

`$ jb install github.com/jsonnet-libs/xtd@v1.0`

_(eg, v1.0 tag does not exist on the xtd repo)_

---

There are also libraries that might have a bit of an alternative naming pattern that
doesn't align well with the `legacyImports` feature. For example
[`istio-libsonnet`](https://github.com/jsonnet-libs/istio-libsonnet) provides multiple
libraries for multiple versions of the Istio CRDs.

Let's install a certain version:

`jb install github.com/jsonnet-libs/istio-libsonnet/1.12@main`

```
.
├── jsonnetfile.json
├── jsonnetfile.lock.json
└── vendor
    ├── 1.12 -> github.com/jsonnet-libs/istio-libsonnet/1.12
    └── github.com
        └── jsonnet-libs
            └── istio-libsonnet
                └── 1.12
                    ├── _gen
                    ├── gen.libsonnet
                    └── main.libsonnet
```

This creates a symlink on `vendor/1.12`, which doesn't express clearly to which
library it refers to and can cause naming conflicts with other libraries following the
same pattern.

---

To overcome this, we can set the name on install:

`jb install github.com/jsonnet-libs/istio-libsonnet/1.12@main --legacy-name istio-lib`

```
.
├── jsonnetfile.json
├── jsonnetfile.lock.json
└── vendor
    ├── github.com
    │   └── jsonnet-libs
    │       └── istio-libsonnet
    │           └── 1.12
    │               ├── _gen
    │               ├── gen.libsonnet
    │               └── main.libsonnet
    └── istio-lib -> github.com/jsonnet-libs/istio-libsonnet/1.12
```

This creates a symlink at `vendor/istio-lib`, which is easily distinguishable.

---

%(example4/jsonnetfile.json)s

Note the `name` attribute on the `dependencies` entry, it has the value of `--legacy-name`
parameter.

Additionally this has the added benefit of doing in-place updates of the istio-lib. This
isn't a standard feature of jsonnet-bundler so we have to manually update
`jsonnetfile.json` and update the `subdir` attribute to `1.13`.

---

```
.
├── jsonnetfile.json
├── jsonnetfile.lock.json
└── vendor
    ├── github.com
    │   └── jsonnet-libs
    │       └── istio-libsonnet
    │           └── 1.13
    │               ├── _gen
    │               ├── gen.libsonnet
    │               └── main.libsonnet
    └── istio-lib -> github.com/jsonnet-libs/istio-libsonnet/1.13
```

Now by calling `jb install` without additional parameters, jsonnet-bundler will replace
this library.

> This is an example on how jsonnet-bundler claims ownership over the `vendor/` directory.
> It will install all libraries to match `jsonnetfile.json` complemented by
> `jsonnetfile.lock.json` and it will remove everything else.

---

### <a id="usage" href="#usage">Usage</a>

Now that we can vendor libraries, it is time to `import` and use them.

Let's use the `xtd` library that we installed:

%(example5/usage1.jsonnet)s

Using the long path is the recommended way on how to import vendored dependencies. It
allows the authors to assume that the `vendor/` directory is in the `JSONNET_PATH` so that
dependencies don't have to be vendored relative to the library.

The long path provides a sufficiently unique path to prevent naming conflicts in most
cases, taking into consideration the usage of `legacyImports` and the alternative naming
pattern explained above.

---

%(example5/usage2.jsonnet)s

If `legacyImports` was set on install, then the symlink allows to import the library with
a short handle like this. Many libraries still follow this practice.

---

%(example5/usage3.jsonnet)s

When using `--legacy-name istio-lib`, the import can look like this.



