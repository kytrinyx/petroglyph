require 'json'

require 'petroglyph/scope'
require 'petroglyph/engine'

module Petroglyph
  def self.compile(data = "", locals = {}, &block)
    if block_given?
      Petroglyph::Engine.start(locals, &block).render
    else
      Petroglyph::Engine.start(locals) { eval data }.render
    end
  end
end
