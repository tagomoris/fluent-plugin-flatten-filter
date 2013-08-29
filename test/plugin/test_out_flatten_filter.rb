require 'helper'

class FlattenFilterOutputTest < Test::Unit::TestCase
  CONFIG = %[
    add_prefix flatten
  ]

  def create_driver(conf=CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::FlattenFilterOutput, tag).configure(conf)
  end

  def test_configure
    d1 = create_driver()
    assert_equal '.', d1.instance.separator

    assert_raise Fluent::ConfigError do
      d = create_driver ''
    end
  end

  def test_retag
    assert_equal 'flatten.test', create_driver("add_prefix flatten").instance.retag('test')
    assert_equal 'flatten.test', create_driver("add_prefix flatten.").instance.retag('test')
    assert_equal 'test', create_driver("remove_prefix raw").instance.retag('raw.test')
    assert_equal 'test', create_driver("remove_prefix raw.").instance.retag('raw.test')
    assert_equal 'flatten.test', create_driver("remove_prefix raw\nadd_prefix flatten").instance.retag('raw.test')
    assert_equal 'flatten', create_driver("remove_prefix raw\nadd_prefix flatten").instance.retag('raw')

    assert_equal 'test.flatten', create_driver("add_suffix flatten").instance.retag('test')
    assert_equal 'test.flatten', create_driver("add_suffix .flatten").instance.retag('test')
    assert_equal 'test', create_driver("remove_suffix raw").instance.retag('test.raw')
    assert_equal 'test', create_driver("remove_suffix .raw").instance.retag('test.raw')
    assert_equal 'test.flatten', create_driver("remove_suffix raw\nadd_suffix flatten").instance.retag('test.raw')
    assert_equal 'flatten', create_driver("remove_suffix raw\nadd_suffix flatten").instance.retag('raw')
  end

  def test_flatten_recursive
    i = create_driver.instance
    assert_equal({"key"=>"value"}, i.flatten_recursive("value", "key"))

    assert_equal({"key.0"=>"value"}, i.flatten_recursive(["value"], "key"))
    assert_equal({"key.0"=>"value0", "key.1"=>"value1"}, i.flatten_recursive(["value0", "value1"], "key"))

    assert_equal({"key.k"=>"value"}, i.flatten_recursive({"k"=>"value"}, "key"))
    assert_equal({"key.k0"=>"value0", "key.k1"=>"value1"}, i.flatten_recursive({"k0"=>"value0","k1"=>"value1"}, "key"))

    data1 = {"key1" => {"subkey1" => {"subsubkey" => "value1"}, "subkey2" => "value2"}, "key2" => "value3"}

    r = create_driver.instance.flatten_recursive(data1, '')
    assert_equal 3, r.keys.size
    assert_equal "value1", r["key1.subkey1.subsubkey"]
    assert_equal "value2", r["key1.subkey2"]
    assert_equal "value3", r["key2"]

    r = create_driver("separator _\nremove_prefix p").instance.flatten_recursive(data1, '')
    assert_equal 3, r.keys.size
    assert_equal "value1", r["key1_subkey1_subsubkey"]
    assert_equal "value2", r["key1_subkey2"]
    assert_equal "value3", r["key2"]

    data2 = {
      "key1" => [{"subsubkey1" => "value1", "subsubkey2" => "value2"}, {"subsubkey1" => "value3", "subsubkey2" => "value4"}],
      "key2" => {"subkey1" => ["value5", "value6", "value7"], "subkey2" => ["value8", "value9"], "subkey3" => [["value10"]]},
    }
    r = create_driver.instance.flatten_recursive(data2, '')
    assert_equal 10, r.keys.size
    assert_equal "value1", r["key1.0.subsubkey1"]
    assert_equal "value2", r["key1.0.subsubkey2"]
    assert_equal "value3", r["key1.1.subsubkey1"]
    assert_equal "value4", r["key1.1.subsubkey2"]
    assert_equal "value5", r["key2.subkey1.0"]
    assert_equal "value6", r["key2.subkey1.1"]
    assert_equal "value7", r["key2.subkey1.2"]
    assert_equal "value8", r["key2.subkey2.0"]
    assert_equal "value9", r["key2.subkey2.1"]
    assert_equal "value10", r["key2.subkey3.0.0"]
  end

  def test_emit
    d = create_driver
    d.run do
      d.emit(
        {
          "key1" => [{"subsubkey1" => "value1", "subsubkey2" => "value2"}, {"subsubkey1" => "value3", "subsubkey2" => "value4"}],
          "key2" => {"subkey1" => ["value5", "value6", "value7"], "subkey2" => ["value8", "value9"], "subkey3" => [["value10"]]},
        }
      )
    end
    emits = d.emits
    assert_equal 1, emits.length
    assert_equal 'flatten.test', emits[0][0] # tag

    r = emits[0][2]
    assert_equal 10, r.keys.size
    assert_equal "value1", r["key1.0.subsubkey1"]
    assert_equal "value2", r["key1.0.subsubkey2"]
    assert_equal "value3", r["key1.1.subsubkey1"]
    assert_equal "value4", r["key1.1.subsubkey2"]
    assert_equal "value5", r["key2.subkey1.0"]
    assert_equal "value6", r["key2.subkey1.1"]
    assert_equal "value7", r["key2.subkey1.2"]
    assert_equal "value8", r["key2.subkey2.0"]
    assert_equal "value9", r["key2.subkey2.1"]
    assert_equal "value10", r["key2.subkey3.0.0"]
  end
end
