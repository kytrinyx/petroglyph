module Petroglyph
  class Scope
    attr_accessor :value, :object, :file

    def initialize(context = nil, locals = {}, template_filename = nil, parent_scope = nil)
      @file = template_filename
      @context = context
      self.copy_instance_variables_from(@context, [:@assigns, :@helpers]) if self.respond_to?(:copy_instance_variables_from)
      @locals = locals
      @parent_scope = parent_scope
      @value = nil
    end

    def sub_scope(object = nil)
      scope = Scope.new(@context, @locals, @file, self)
      scope.object = object
      scope
    end

    def node(input, &block)
      @value ||= {}
      scope = nil
      name = nil
      value = nil
      if input.is_a?(Hash)
        raise ArgumentError, "node can't deal with more than one key at a time" if input.keys.size > 1
        name = input.keys.first
        value = input.values.first
      else
        name = input
      end

      if block_given?
        scope = sub_scope(value)
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

    def merge(hash, &block)
      @value ||= {}
      if block_given?
        scope = sub_scope(hash)
        scope.instance_eval(&block)
        hash = scope.value
      end
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

    def partial(name, locals = {})
      data = Petroglyph.partial(name, file)
      scope = Scope.new(@context, locals, file)
      scope.instance_eval(data.to_s)
      merge scope.value
    end

    def method_missing(method, *args, &block)
      if @locals and @locals.has_key?(method)
        @locals[method]
      elsif @context.respond_to?(method)
        @context.send(method, *args)
      else
        super
      end
    end

  end
end
