module Petroglyph
  class Scope
    attr_accessor :value, :object, :file

    def initialize(context = nil, locals = {}, template_filename = nil, parent_scope = nil)
      @file = template_filename
      @context = context
      self.copy_instance_variables_from(@context, [:@assigns, :@helpers]) if self.respond_to?(:copy_instance_variables_from)
      @locals = locals
      @parent_scope = parent_scope
      @value = {}
    end

    def sub_scope(object = nil)
      scope = Scope.new(@context, @locals, @file, self)
      scope.object = object
      scope
    end

    def node(input, &block)
      if input.is_a?(Hash) && input.keys.size > 1
        raise ArgumentError, "node can't deal with more than one key at a time"
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

    def collection(args, hash = nil, &block)
      if args.is_a?(Hash)
        name, items = args.first

        if args.length == 2
          block = eval_block(args)
        end
      else
        items = args

        unless hash.nil?
          block = eval_block(hash)
        end
      end

      results = items.map do |item|
        sub_scoped(item, &block)
      end

      if name
        @value[name] = results
      else
        @value.empty? ? @value = results : @value.merge!(Hash.new(results))
      end
    end

    def merge(hash, &block)
      if block_given?
        hash = sub_scoped(hash, &block)
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

    def partial(name, locals = nil)
      locals ||= {name => send(name)} if respond_to?(name)
      locals ||= {}
      partial  = Petroglyph.partial(name, file)
      scope = Scope.new(@context, locals, file)
      scope.instance_eval(&partial)
      merge scope.value
    end

    def respond_to?(method)
      super || local?(method)
    end

    def method_missing(method, *args, &block)
      if local?(method)
        @locals[method]
      elsif @context.respond_to?(method)
        @context.send(method, *args)
      else
        super
      end
    end

    private

    def local?(method)
      @locals and @locals.has_key?(method)
    end

    def eval_block(args)
      singular = args[:partial]
      eval "Proc.new{|item| partial #{singular.inspect}, #{singular.inspect} => item}"
    end

    def sub_scoped(value, &block)
      scope = sub_scope(value)
      scope.instance_exec(value, &block)
      scope.value
    end
  end
end
