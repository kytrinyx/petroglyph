# Makes Petroglyph available through Tilt.
# A lso contains a utility function that will
# be added to Sinatra if Sinatra is defined.

require 'tilt'

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
      Petroglyph.compile(data, locals) # what about the block?
      # input = eval data
      # template = Petroglyph::Template.build(locals, input)
      # template.render
      #Mustache.render(Fu.to_mustache(data), locals.merge(scope.is_a?(Hash) ? scope : {}).merge({:yield => block.nil? ? '' : block.call}))
    end
  end
  register PetroglyphTemplate, 'pg'
end

if defined?(Sinatra)
  module Sinatra::Templates
    def pg(template, options={}, locals={})
      render :pg, template, options, locals
    end
  end
end
