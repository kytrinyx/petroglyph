module Petroglyph
  class Node
    attr_accessor :name, :value, :object

    def initialize(parent_context = nil, locals = {})
      @parent_context = parent_context
      @locals = locals
      @value = {}
    end

    def merge(hash)
      @value.merge!(hash)
    end

    def node(name, value = nil, &block)
      node = Node.new
      node.name = name
      if block_given?
        node.value = yield
      else
        node.value = value
      end
      @value = @value.merge node.to_hash
    end

    def attributes(*args)
      fragment = {}
      args.each do |method|
        fragment[method] = @object.send(method)
      end
      @value.merge! fragment
    end

    def to_hash
      {name => value}
    end

    def method_missing(method, *args, &block)
      if @locals.has_key?(method)
        @locals[method]
      else
        @parent_context.send method, *args, &block
      end
    end

  end
end
