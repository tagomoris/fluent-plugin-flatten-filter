module Fluent
  class FlattenFilterOutput < Output
    Fluent::Plugin.register_output('flatten_filter', self)

    config_param :separator, :string, :default => '.'
    # config_param :max_depth, :integer, :default => -1 # inf # not implemented

    config_param :remove_prefix, :string, :default => nil
    config_param :add_prefix, :string, :default => nil

    config_param :remove_suffix, :string, :default => nil
    config_param :add_suffix, :string, :default => nil

    def initialize
      super
    end

    def configure(conf)
      super

      if !@remove_prefix && !@add_prefix && !@remove_suffix && !@add_suffix
        raise Fluent::ConfigError, "No one tag handling options specified"
      end

      if @remove_prefix
        @removed_prefix_string = (@remove_prefix.end_with?('.') ? @remove_prefix : @remove_prefix + '.')
        @removed_prefix_length = @removed_prefix_string.length
      end
      if @add_prefix
        @added_prefix_string = (@add_prefix.end_with?('.') ? @add_prefix : @add_prefix + '.')
      end
      if @remove_suffix
        @removed_suffix_string = (@remove_suffix.start_with?('.') ? @remove_suffix : '.' + @remove_suffix)
        @removed_suffix_length = @removed_suffix_string.length
      end
      if @add_suffix
        @added_suffix_string = (@add_suffix.start_with?('.') ? @add_suffix : '.' + @add_suffix)
      end
    end

    def retag(tag)
      if @remove_prefix && (tag.start_with?(@removed_prefix_string) || tag == @remove_prefix)
        tag = tag[@removed_prefix_length..-1] || ''
      end
      if @add_prefix
        tag = (tag.length > 0 ? @added_prefix_string + tag : @add_prefix.dup)
      end
      if @remove_suffix && (tag.end_with?(@removed_suffix_string) || tag == @remove_suffix)
        tag = tag[0,(tag.length - @removed_suffix_length)] || ''
      end
      if @add_suffix
        tag = (tag.length > 0 ? tag + @added_suffix_string : @add_suffix.dup)
      end
      tag
    end

    def flatten_recursive(obj, key_prefix)
      next_key_prefix = key_prefix.empty? ? '' : key_prefix + @separator
      r = {}

      if obj.is_a?(Hash)
        obj.each do |key,value|
          r.update(flatten_recursive(value, next_key_prefix + key))
        end
      elsif obj.is_a?(Array)
        obj.each_with_index do |item, i|
          r.update(flatten_recursive(item, next_key_prefix + i.to_s))
        end
      else
        r[key_prefix] = obj
      end

      r
    end

    def emit(tag, es, chain)
      t = retag(tag)
      es.each do |time,record|
        Fluent::Engine.emit(t, time, flatten_recursive(record, ''))
      end
      chain.next
    end
  end
end
