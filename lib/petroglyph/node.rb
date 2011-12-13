module Petroglyph
  class Node
    attr_accessor :value, :object

    def initialize(template_context = nil, locals = {}, parent_node = nil)
      @template_context = template_context
      @locals = locals
      @parent_node = parent_node
      @value = nil
    end

    def sub_node(object = nil)
      node = Node.new(@template_context, @locals, self)
      node.object = object
      node
    end

    def node(name, value = nil, &block)
      @value ||= {}
      node = nil
      if name.is_a?(Hash)
        node = sub_node(name.values.first)
        name = name.keys.first
      else
        node = sub_node
      end

      if block_given?
        node.instance_eval(&block)
        @value[name] = node.value if node.value
      else
        @value[name] = value
      end
    end

    def merge(hash)
      @value ||= {}
      @value.merge!(hash)
    end

    def attributes(*args)
      fragment = {}
      args.each do |method|
        if @object.respond_to?(method)
          fragment[method] = @object.send(method)
        else
          fragment[method] = @object[method]
        end
      end
      merge fragment
    end

    def method_missing(method, *args, &block)
      if @locals.has_key?(method)
        @locals[method]
      else
        @template_context.send method, *args, &block
      end
    end

  end
end
