require 'tilt/petroglyph'

if defined?(Sinatra)
  module Sinatra::Templates
    def pg(template, options={}, locals={})
      render :pg, template, options, locals
    end
  end
end
