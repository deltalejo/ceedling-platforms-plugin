# Platforms Ceedling Plugin

Support building for multiple platforms with [Ceedling](ceedling).

The plugin behaves very similar to the `project:<name>` option, but allows the
extra project files to be inside some folder that can be specified, keeping your
project root clean of `.yml` files if you are handling a lot of them.

## Installation

Create a folder in your machine for Ceedling plugins if you do not have one
already. *e.g.* `~/some/place/for/plugins`:

```shell
$ mkdir -p ~/some/place/for/plugins
```

### Get the plugin

`cd` into the plugins folder and clone this repo:

```shell
$ cd ~/some/place/for/plugins
$ git clone https://github.com/deltalejo/platforms-ceedling-plugin.git
```

### Enable the plugin

Add the plugins path to your `project.yml` to tell Ceedling where to find
them if you have not done it yet. Then add `platforms` plugin to the enabled
plugins list:

```yaml
:plugins:
  :load_paths:
    - ~/some/place/for/plugins
  :enabled:
    - platforms
```

## Usage

Add the folder(s) which contains (or will contain) the extra project files to
your `project.yml`:

```yaml
:project:
  :platforms_paths:
    - platforms
```

Put the extra project files inside the specified folder:

```
.
├── platforms
│   ├── platform-1.yml
│   ├── platform-2.yml
│   └── platform-3.yml
├── src
├── test
└── project.yml
```

Call Ceedling specifying the desired platform. *e.g.*:

```shell
$ ceedling platform:platform-1 test:all
```

[ceedling]: https://github.com/ThrowTheSwitch/Ceedling
