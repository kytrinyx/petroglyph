module Petroglyph

  class Engine

    attr_accessor :data

    def self.start(locals = {}, &block)
      parent_context = eval "self", block.binding
      t = self.new
      page = Scope.new(parent_context, locals)
      page.instance_eval(&block)
      t.data = page.value
      t
    end

    def render
      @data.to_json
    end

  end
end
