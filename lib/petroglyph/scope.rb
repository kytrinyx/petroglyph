module Petroglyph
  class Scope
    attr_accessor :value, :object

    def initialize(template_context = nil, locals = {}, parent_scope = nil)
      @template_context = template_context
      @locals = locals
      @parent_scope = parent_scope
      @value = nil
    end

    def sub_scope(object = nil)
      scope = Scope.new(@template_context, @locals, self)
      scope.object = object
      scope
    end

    def node(name, value = nil, &block)
      @value ||= {}
      scope = nil
      if name.is_a?(Hash)
        scope = sub_scope(name.values.first)
        name = name.keys.first
      else
        scope = sub_scope
      end

      if block_given?
        scope.instance_eval(&block)
        @value[name] = scope.value if scope.value
      else
        @value[name] = value
      end
    end

    def collection(input, &block)
      @value ||= {}
      name = input.keys.first
      items = input.values.first
      results = []
      items.each do |item|
        scope = sub_scope(item)
        scope.instance_exec(item, &block)
        results << scope.value
      end
      @value[name] = results
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
