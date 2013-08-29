# fluent-plugin-flatten-filter

**This plugin is yanked. Use fluent-plugin-flatten-hash instead.**

Fluentd plugin to flatten container values (hashes and arrays) into flat single record recursively, and re-emit it.

### For example

Source record:

    { "field1" => "value1",
      "field2" => { "key1" => "str1", "key2" => "str2", "key3" => "str3" },
      "field3" => [ "data1", "data2", "data3" ],
      "field4" => [ { "k1" => "v1", "k2" => "v2" }, { "k1" => "v1", "k2" => "v2" } ] }

Destination record:

    { "field1" => "value1",
      "field2.key1" => "str1",
      "field2.key2" => "str2",
      "field2.key3" => "str3",
      "field3.0" => "data1",
      "field3.1" => "data2",
      "field3.2" => "data3",
      "field4.0.k1" => "v1",
      "field4.0.k2" => "v2",
      "field4.1.k1" => "v1",
      "field4.1.k2" => "v2" }

Separator character of key elements is configurable.

## Configuration

Most simple configuration is here (output record with tag `data`):

    <match raw.data>
      type flatten_filter
      remove_prefix raw
    </match>

Tag conversion is required, so you must specify at least one of `remove_prefix`, `add_prefix`, `remove_suffix` and `add_suffix`.

### Configuration options

* separator (default '.')
  * separator character(or, string) of key elements
* remove_prefix
* add_prefix
* remove_suffix
* add_suffix

## TODO

* patches welcome!

## Copyright

* Copyright (c) 2013- TAGOMORI Satoshi (tagomoris)
* License
  * Apache License, Version 2.0
