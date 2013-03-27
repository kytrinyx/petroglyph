# Makes Petroglyph available through Tilt.
require 'tilt'
require 'petroglyph'

module Tilt
  class PetroglyphTemplate < Template
    self.default_mime_type = "application/json"
    def initialize_engine
      return if defined? ::Petroglyph
      require_template_library 'petroglyph'
    end

    def prepare
      @engine = Petroglyph::Engine.new(data)
    end

    def precompiled_template(locals)
      data.to_str
    end

    def evaluate(scope = Object.new, locals = {}, &block)
      @engine.render(scope, locals, file, &block)
    end
  end
  register PetroglyphTemplate, 'pg'
end
