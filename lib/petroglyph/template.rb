# TILT Template
if defined?(Tilt)
  class PetroglyphTemplate < Tilt::Template
    def initialize_engine
      return if defined?(::Petroglyph)
      require_template_library 'petroglyph'
    end

    def prepare
      options = @options.merge(:source_location => file)
      @engine = ::Petroglyph::Engine.new(data, options)
    end

    def evaluate(scope, locals, &block)
      @engine.render(scope, locals, &block)
    end
  end

  Tilt.register 'pg', PetroglyphTemplate
end

# Rails 2.X Template
if defined?(Rails) && Rails.version =~ /^2/
  require 'action_view/base'
  require 'action_view/template'

  module ActionView
    module TemplateHandlers
      class PetroglyphHandler < TemplateHandler
        include Compilable

        def compile(template) %{
          ::Petroglyph::Engine.new(#{template.source.inspect}).
            render(self, assigns.merge(local_assigns), '#{template.filename}')
        } end
      end
    end
  end

  ActionView::Template.register_template_handler :pg, ActionView::TemplateHandlers::PetroglyphHandler
end

# Rails 3.X Template
if defined?(Rails) && Rails.version =~ /^3/
  module ActionView
    module Template::Handlers
      class Petroglyph

        def call(template)
          source = if template.source.empty?
            File.read(template.identifier)
          else
            template.source
          end

          %{ ::Petroglyph::Engine.new(#{source.inspect}).
              render(self, assigns.merge(local_assigns), '#{template.identifier}') }
        end
      end
    end
  end

  ActionView::Template.register_template_handler :pg, ActionView::Template::Handlers::Petroglyph.new
end
