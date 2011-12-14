require 'json'

require 'petroglyph/scope'
require 'petroglyph/template'

module Petroglyph
  def self.compile(data = "", locals = {}, &block)
    if block_given?
      Petroglyph::Template.build(locals, &block).render
    else
      Petroglyph::Template.build(locals) { eval data }.render
    end
  end
end
