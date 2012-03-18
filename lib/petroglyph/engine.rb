module Petroglyph
  class Engine

    def initialize(data = nil)
      @data = data
    end

    def render(context = Object.new, locals = {}, file = nil, &block)
      to_hash(locals, file, context, &block).to_json
    end

    def to_hash(locals = {}, file = nil, context = Object.new, &block)
      scope = Scope.new(context, locals, file)

      scope.instance_eval(@data) if @data
      scope.instance_eval(&block) if block_given?

      scope.value
    end
  end
end
