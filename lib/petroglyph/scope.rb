module Petroglyph
  class Scope
    attr_accessor :file
    attr_reader :object, :value

    def initialize(context = nil, locals = {}, template_filename = nil, parent_scope = nil, object=nil)
      @file = template_filename
      @context = context
      self.copy_instance_variables_from(@context, [:@assigns, :@helpers]) if self.respond_to?(:copy_instance_variables_from)
      @locals = locals
      @parent_scope = parent_scope
      @value = {}
      @object = object
    end

    def sub_scope(object = nil)
      Scope.new(@context, @locals, @file, self, object)
    end

    def node(input, &block)
      if input.is_a?(Hash) && input.keys.size != 1
        raise ArgumentError, "node can only deal with one key at a time"
      end

      if input.is_a?(Hash)
        name = input.keys.first
        value = input.values.first
      else
        name = input
        value = nil
      end

      if block_given?
        @value[name] = sub_scoped(value, &block)
      else
        @value[name] = value
      end
    end

    def collection(args, hash = {}, &block)
      if args.is_a?(Hash)
        name, items = args.first
        partial = args[:partial]
      else
        items = args
        partial = hash[:partial]
      end

      block = eval_block(partial) if partial

      results = items.map do |item|
        sub_scoped(item, &block)
      end

      if name
        @value[name] = results
      elsif @value.empty?
        @value = results
      else
        fail "A collection was calculated but thrown away"
      end
    end

    def merge(hash, &block)
      if block_given?
        @value.merge!(sub_scoped(hash, &block))
      else
        @value.merge!(hash)
      end
    end

    def attributes(*args)
      args.each do |method|
        if @object.respond_to?(method)
          @value[method] = @object.send(method)
        else
          @value[method] = @object[method]
        end
      end
    end

    def partial(name, locals = nil)
      locals ||= {name => send(name)} if respond_to?(name)
      locals ||= {}
      partial  = Petroglyph.partial(name, file)
      scope = Scope.new(@context, locals, file)
      scope.instance_eval(&partial)
      merge scope.value
    end

    def respond_to?(method, include_all = false)
      super || local?(method) || @context.respond_to?(method, include_all)
    end

    def method_missing(method, *args, &block)
      if local?(method)
        @locals[method]
      elsif @context.respond_to?(method, *args)
        @context.send(method, *args)
      else
        super
      end
    end

    private

    def local?(method)
      @locals and @locals.has_key?(method)
    end

    def eval_block(singular)
      eval "Proc.new{|item| partial #{singular.inspect}, #{singular.inspect} => item}"
    end

    def sub_scoped(value, &block)
      scope = sub_scope(value)
      scope.instance_exec(value, &block)
      scope.value
    end
  end
end
