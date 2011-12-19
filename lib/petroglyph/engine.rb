module Petroglyph
  class Engine

    def initialize(data = nil)
      @data = data
    end

    def render(context = Object.new, locals = {}, &block)
      data = @data
      scope = Scope.new(context, locals)
      if data
        scope.instance_eval(data)
      else
        scope.instance_eval(&block)
      end
      scope.value.to_json
    end
  end
end
