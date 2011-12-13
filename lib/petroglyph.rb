require 'json'

module Petroglyph

  class Fragment
    def initialize(parent_context, locals)
      @parent_context = parent_context
      @locals = locals
      @root = {}
    end

    def node(name, value = nil, &block)
      if name.is_a?(Hash)
        @object = name.values.first
        name = name.keys.first
      end

      if block_given?
        @root = @root.merge(name => yield)
      else
        @root = @root.merge(name => value)
      end

      @root
    end

    def merge(hash)
      @root = @root.merge hash
    end

    def attributes(*args)
      fragment = {}
      args.each do |method|
        fragment[method] = @object.send(method)
      end
      fragment
    end

    def collection(input, &block)
      name = input.keys.first
      values = input.values.first
      results = []
      values.each do |value|
        @object = value
        results << block.call(value)
      end
      node(name, results)
    end

    def method_missing(method, *args, &block)
      if @locals.has_key?(method)
        @locals[method]
      else
        @parent_context.send method, *args, &block
      end
    end

  end

  class Template

    def self.build(locals = {}, &block)
      parent_context = eval "self", block.binding
      t = self.new
      t.data = Fragment.new(parent_context, locals).instance_eval(&block)
      t
    end

    def data=(data)
      @data = data
    end

    def render
      @data.to_json
    end

  end
end
