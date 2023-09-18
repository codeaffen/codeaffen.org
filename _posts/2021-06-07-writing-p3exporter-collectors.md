---
layout: post
title: How to write new p3exporter collectors
subtitle: Let's start contributing
tags: [project, p3exporter, prometheus, collector, contributing]
author: cmeissner
gh-repo: codeaffen/p3exporter
gh-badge: [star, watch, fork, follow]
---

We started to develop the `python programmable prometheus exporter` aka [p3exporter](https://github.com/codeaffen/p3exporter) to help interested sys- and devops to quickstart their prometheus exporter development.
Here we currently provide only two real life collectors (netdev and loadavg) and one example conllector. But the concept of `p3exporter` is to provide a simple framework to ease your own collector development.

We want to provide a walkthrough how to to enable you to start with developing you own collectors or help to extend the collectors comming with our project.

## Naming convention

To provide the framework you have to follow a short but strict naming convention. If you meet all rules that your collector will be recognized and loaded by `p3exporter`.
The collector module file needs at least one class according to the following naming scheme.

file name | collector name | class name
:--- | :--- | :---
my.py | my | MyCollector
foo_bar.py | foo_bar | FooBarCollector
foo_bar_baz.py | foo_bar_baz | FooBarBazCollector

### file and collector name

* file and collector name has to be in lower case
* if the name consists of more then one word it has to be in `snake_case`

### class name

* class name start with a capital letter
* if the collector name consists of more then one word it has to be in `CamelCase`
* the class name has to end on `Collector`

### class method

To enable the collector class to act as a collector it needs a least a generator method called `collect`. It has to `yield` the desired metrics.

## a simple example

In the following section we compose a very simple example to show what is neede as a minimum. We will show step by step what you need to do.

### imports

To create a working collector you need to import some few modules. To get some cool features and the possibility to configure your collector from `p3.yml` you need to import the following classes from the `p3exporter.collector` module.

```python
from p3exporter.collector import CollectorBase, CollectorConfig
```

To let your collector provide metrics you have to import the needed `*MetricFamily` class from `prometheus_client.core` module. For that howto we simply use `InfoMetricFamily` class to let our collector export a simple info metric.

```python
from prometheus_client.core import InfoMetricFamily
```

### collector class

The collector needs to provide a class with name mentioned in [class name section](#class-name). The class need to derives from `CollectorBase`.

```python
class HowtoExampleCollector(CollectorBase):
```

The minimum methods the class has to implement a method called `collect`. This method needs to be a generator. For this howto we decided to simply export a simple info metric.

```python
def collect(self):
    yield InfoMetricFamily('howto_example', 'a simple example info metric', value={'status': 'green'})
```

## configure your collector

Often it is useful to provide configuration parameters for your collector. The faciliy for that is already implemented in `p3exporter.collector`.
The second portion is to import the `CollectorConfig` class from `p3exporter.collector` module.
Now you can add a `__init__` method with a config parameter of type `CollectorConfig`.

```python
def __init__(self, config: CollectorConfig):
    super(HowtoExampleCollector, self).__init__(config)
```

Both classes `CollectorBase` and `CollectorConfig` provides the facility to bring options into your collector.

Collector specific options have to be placed in `p3.yml` like that:

```yaml
collector_opts:
  howto_example:
    our_opt: our_val
```

And you can access your collectors options via a instance variable called `self.opts`.

```python
    def __init__(self, config: CollectorConfig):

        super(HowtoExampleCollector, self).__init__(config)

        self.our_opt = self.opts.pop("our_opt", None)
```

### putting all together

With such few snippets we have a working collector. It should now looks like that:

```python
from p3exporter.collector import CollectorBase, CollectorConfig
from prometheus_client.core import InfoMetricFamily

class HowtoExampleCollector(CollectorBase):

    def __init__(self, config: CollectorConfig):

redirect_from: /2021-06-07-writing-p3exporter-collectors/
        super(HowtoExampleCollector, self).__init__(config)

        self.our_opt = self.opts.pop("our_opt", None)

    def collect(self):
        yield InfoMetricFamily('howto_example', 'a simple example info metric', value={'status': self.our_opt})

```

## What comes next

To create a full documented and tested collector you also have to add [docstrings](https://www.python.org/dev/peps/pep-0257/){:target="_blank"}.
Here you are invited to have a look to our existing collectors on github.
