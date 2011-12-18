# Makes Petroglyph available through Tilt.
# Also contains a utility function that will
# be added to Sinatra if Sinatra is defined.

require 'tilt'
require 'petroglyph'

module Tilt
  class PetroglyphTemplate < Template
    self.default_mime_type = "application/json"
    def initialize_engine
      return if defined? ::Petroglyph
      require_template_library 'petroglyph'
    end

    def prepare; end

    def precompiled_template(locals)
      data.to_str
    end

    def evaluate(scope, locals, &block)
      Petroglyph.compile(data, locals)
    end
  end
  register PetroglyphTemplate, 'pg'
end
