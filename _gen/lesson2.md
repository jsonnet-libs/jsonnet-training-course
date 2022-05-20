# Don't write libraries

There are a ton of Jsonnet libraries out there, ranging from big generated libraries
to manually curated for a very specific purpose. Let's have a look at how to find and
vendor them.


## Objectives

- Find existing libraries
- Vendor libraries with `jsonnet-bundler`
- Use a vendored library with `JSONNET_PATH`
- Develop on a vendored library
- Generate new libraries from specifications

## Lesson

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

Now that we can find libraries, we need a way to "install" them. Jsonnet libraries are
distributed as source code,  makes it quite simple process.

The [`jsonnet-bundler`](https://github.com/jsonnet-bundler/jsonnet-bundler/) project is
the de facto package manager for Jsonnet. It vendors libraries from Git repositories and
tracks them in `jsonnetfile.json`and its corresponding lockfile `jsonnetfile.lock.json`.

To get started, initialize the directory with the `jb init`:

```json
{
  "version": 1,
  "dependencies": [],
  "legacyImports": true
}

// example1.jsonnetfile.json
```


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

```json
{
  "version": 1,
  "dependencies": [
    {
      "source": {
        "git": {
          "remote": "https://github.com/jsonnet-libs/xtd.git",
          "subdir": ""
        }
      },
      "version": "master"
    }
  ],
  "legacyImports": true
}

// example2/jsonnetfile.json
```


`jsonnetfile.json` has a new entry in the `dependency` key, it refers to the source on
Github and defaults to the `master` branch for tracking its `version`.

---

```json
{
  "version": 1,
  "dependencies": [
    {
      "source": {
        "git": {
          "remote": "https://github.com/jsonnet-libs/xtd.git",
          "subdir": ""
        }
      },
      "version": "803739029925cf31b0e3c6db2f4aae09b0378a6e",
      "sum": "d/c+3om56mfddeYWrsxOwsrlH008BmX/5NoquXMj0+g="
    }
  ],
  "legacyImports": false
}

// example2/jsonnetfile.lock.json
```


A new file `jsonnetfile.lock.json` is created, this contains the actual `version` that
should be installed, as this is a Git source it refers to a Git hash. Additionally it also
tracks a checksum value in `sum`.

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

It is often not necessary and even undesirable to distribute `jsonnetfile.lock.json` or
`vendor` along with your library, the `version` tag in `jsonnetfile.json` can be leveraged
in case a specific version is expected (for example when newer versions of dependencies have breaking changes).


## Conclusion

TODO
