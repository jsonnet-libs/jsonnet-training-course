# Understanding Package management

There are a ton of Jsonnet libraries out there, ranging from big generated libraries
to manually curated for a very specific purpose. Let's have a look at how to find and
vendor them.


## Objectives

- Find libraries
- Install and update with jsonnet-bundler
- Import a library on the `JSONNET_PATH`
- Handle common use cases

## Lesson

The ecosystem for Jsonnet libraries has organically grown, there is no central entity in
control. Even though this gives the authors a great deal of autonomy, it makes it harder
to find libraries. The majority of libraries are open source and can be found in Git
repositories.

- GitHub Topic [`jsonnet-lib`](https://github.com/topics/jsonnet-lib) lists the libraries
    that are tagged with `jsonnet-lib`. Cultivating this tag is encouraged.
- In the observability space, there is a sub-ecosystem of "mixins". The [Monitoring
    Mixins project](https://monitoring.mixins.dev/) is an effort to centralize them.
- Keyword search on GitHub:
    - [`jsonnet-libs`](https://github.com/search?q=jsonnet-libs)
        Organisations often share their libraries in such a repository.
    - [`libsonnet`](https://github.com/search?q=libsonnet)
        Libraries are often suffixed with `-libsonnet`
- Some applications offer Jsonnet libraries to deploy, configure and/or monitor their
    application, look for a `jsonnetfile.json` in their repository.
- A few community members maintain an 'awesome list':
    - https://github.com/MacroPower/awesome-jsonnet
    - https://github.com/metalmatze/awesome-jsonnet
    - https://github.com/sh0rez/awesome-libsonnet

---

### jsonnet-bundler

Now that we can find libraries, we need a way to "install" them. Jsonnet libraries are
distributed as source code, making it a relatively simple process.

The de facto package manager for Jsonnet is
[jsonnet-bundler](https://github.com/jsonnet-bundler/jsonnet-bundler/), we'll use it to
fetch libraries and managed dependencies. Have a look at the project README to install it.

To get started, initialize the directory:

`$ jb init`

Then "install" a library, [`xtd`](https://github.com/jsonnet-libs/xtd) for example:

`$ jb install github.com/jsonnet-libs/xtd`

To use it, `import` the main file:

```jsonnet
local xtd = import 'github.com/jsonnet-libs/xtd/main.libsonnet';

xtd.ascii.isNumber('2')

// example5/usage1.jsonnet
```


And finally execute it with:

`$ jsonnet -J vendor/ usage1.jsonnet`

---

#### Under the hood

Now that we have covered the basics, let's have a look at what each command does under the
hood and how it manipulates these files.

Jsonnet-bundler vendors libraries from Git repositories and tracks them in
`jsonnetfile.json`and its corresponding lockfile `jsonnetfile.lock.json`.

```json
{
  "version": 1,
  "dependencies": [],
  "legacyImports": true
}

// example1/jsonnetfile.json
```


`$ jb init` creates a virtually empty `jsonnetfile.json`.

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
      "version": "master"
    }
  ],
  "legacyImports": true
}

// example2/jsonnetfile.json
```


`$ jb install github.com/jsonnet-libs/xtd` adds a new entry to the `dependencies` in
`jsonnetfile.json`, the entry refers to the git source on GitHub and the `master` branch
for its tracking `version`.

When updating libraries, it will use the tracking `version`, for example `$ jb update
github.com/jsonnet-libs/xtd` will pull in the git commit that `master` refers to.

> **Tracking version**
>
> The default tracking `version` used by jsonnet-bundler is `master`, new GitHub repos
> default to the `main` tag. To override this, add `@main` to the URI:
>
> `$ jb install github.com/jsonnet-libs/xtd@main`


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
`vendor/xtd` was added. The `vendor/` directory is a widespread convention.

---

When shipping a library, generally only a `jsonnetfile.json` is included. This way when
calling `jb install` on a library, it will fetch the source corresponding to the tracking
`version`. For example, if that is `master` it will match the latest git commit for that
branch.

It is often not necessary and even undesirable to distribute `jsonnetfile.lock.json` and
`vendor/` with a library, the `version` tag in `jsonnetfile.json` should be sufficient to
pin a specific version (for example when [upstream has breaking
changes](#upstream-has-breaking-changes)).

```gitignore
jsonnetfile.lock.json
vendor/

// example3/.gitignore
```


Add a `.gitignore` file with `jsonnetfile.lock.json` and `vendor/` so they are not
accidentally committed.

### Usage

As shown before, to use a library it needs to be imported:

```jsonnet
local xtd = import 'github.com/jsonnet-libs/xtd/main.libsonnet';

xtd.ascii.isNumber('2')

// example5/usage1.jsonnet
```


Using the long path is the recommended way to import vendored dependencies. It builds on
the assumption that the `vendor/` directory is in the [`JSONNET_PATH`](#jsonnet_path) so
that dependencies don't have to be vendored relative to the library.

The long path provides a sufficiently unique path to prevent naming conflicts in most
cases, the edge cases are covered in [Common use cases](#common-use-cases) below.

---

```jsonnet
local xtd = import 'xtd/main.libsonnet';

xtd.ascii.isNumber('2')

// example5/usage2.jsonnet
```


If `legacyImports` was `true` on install, then the symlink allows to import the library
with a short handle like this. Many libraries still follow this practice.

---

> **Legacy Imports**
>
> Originally `jb` vendored libraries as `vendor/<name>`, but in large code bases this can
> cause naming conflicts. To resolve this, `jb` started vendoring on the full repository
> path `github.com/<org>/<repo>/<path/to/lib>/name`. Many libraries have references to the
> short path, and for that `"legacyImports": true` tells `jb` to also create a symlink to
> this full path on the short path `vendor/<name>` to keep this working.


### `JSONNET_PATH`

`JSONNET_PATH` is a list of directories that `jsonnet` will attempt to resolve imports
from. Two common paths are `vendor/` and `lib/`, relative to the project root, which is
usually indicated by a `jsonnetfile.json`. The `-J` parameter on `jsonnet` can be used for
this:

`$ jsonnet -J vendor/ -J lib/ usage2.jsonnet`

_Order matters: `-J` follows LIFO, if the import is found in `lib/` then it will not look
in `vendor/`._

This will resolve the imports until it finds a match:

- ✗ `./xtd/main.libsonnet`
- ✗ `./lib/xtd/main.libsonnet`
- ✓ `./vendor/xtd/main.libsonnet`

As we don't want to pass the `-J` parameters each time, we can also set the `JSONNET_PATH`
variable in our environment:

`$ export JSONNET_PATH="lib/:vendor/"`

`$ jsonnet usage2.jsonnet`

_Order matters: `JSONNET_PATH` follows FIFO, if the import is found in `lib/` then it will
not look in `vendor/`._

### Common use cases

As package management is quite distributed and jsonnet-bundler is relatively simple, there
are some use cases that don't get covered well. Fortunately Jsonnet and jsonnet-bundler
are quite flexible.

#### Upstream has breaking changes

It may happen that the upstream tracking branch (eg. `master`) introduce breaking changes.
A first response may be to ship the `jsonnetfile.lock.json` alongside the library, however
this also pins the version of all other libraries, which is often undesirable. It would be
better to pin the version in `jsonnetfile.json`.

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
      "version": "803739029925cf31b0e3c6db2f4aae09b0378a6e"
    }
  ],
  "legacyImports": true
}

// example3/jsonnetfile.json
```


This can be done by setting tracking `version` on a dependency, you can use `jb install`
for this.

If authors are aware, then they often provide a version tag (eg. `v1.0`):

`$ jb install github.com/jsonnet-libs/xtd@v1.0`

_(eg. v1.0 tag does not exist on the xtd repo)_

It is also possible to pin to a very specific commit:

`$ jb install github.com/jsonnet-libs/xtd@803739029925cf31b0e3c6db2f4aae09b0378a6e`

#### Alternative naming pattern

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

This creates a symlink on `vendor/1.12`, which doesn't express clearly to
which library it refers to and can cause naming conflicts with other libraries following
the same pattern.

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

`--legacy-name` creates a symlink at `vendor/istio-lib` instead of `vendor/1.12`, which
makes it easily distinguishable.

---

```json
{
  "version": 1,
  "dependencies": [
    {
      "source": {
        "git": {
          "remote": "https://github.com/jsonnet-libs/istio-libsonnet.git",
          "subdir": "1.13"
        }
      },
      "version": "main",
      "name": "istio-lib"
    }
  ],
  "legacyImports": true
}

// example4/jsonnetfile.json
```


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

> This is an example of how jsonnet-bundler claims ownership over the `vendor/` directory.
> It will install all libraries to match `jsonnetfile.json` complemented by
> `jsonnetfile.lock.json` and it will remove everything else.

---

```jsonnet
local istiolib = import 'istio-lib/main.libsonnet';

istiolib.networking.v1beta1.virtualService.new('test')

// example5/usage3.jsonnet
```


When using `--legacy-name istio-lib`, the import can look like this.

#### Shortcut in `lib/`

Another pattern to naming a dependency with jsonnet-bundler is to create a local library
with the purpose of providing a shortcut.

```jsonnet
(import 'github.com/jsonnet-libs/istio-libsonnet/1.13/main.libsonnet')

// example5/lib/istiolib.libsonnet
```


```jsonnet
local istiolib = import 'istiolib.libsonnet';

istiolib.networking.v1beta1.virtualService.new('test')

// example5/usage4.jsonnet
```


The added advantage of this approach is the ability to add local overrides for the library
in `lib/istiolib.libsonnet`. It is also doesn't depend on the `jsonnet-bundler` behavior.

Note the location of this library, `lib/`, is another directory is commonly added to
[`JSONNET_PATH`](#jsonnet_path) from where libraries can `import` dependencies.


## Conclusion

Finding libraries and package managemet can be cumbersome, nonetheless
jsonnet-bundler makes it a bit easier to work with the distributed ecosystem.
Additionally `JSONNET_PATH` offers a level of flexibility to work around the package
management shortcomming.


