module Petroglyph

  class Template

    attr_accessor :data

    def self.build(locals = {}, &block)
      parent_context = eval "self", block.binding
      t = self.new
      page = Node.new(parent_context, locals)
      page.instance_eval(&block)
      t.data = page.value
      t
    end

    def render
      @data.to_json
    end

  end
end
