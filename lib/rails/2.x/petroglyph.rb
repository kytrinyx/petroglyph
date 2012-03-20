if defined?(Tilt)
  require 'tilt/petroglyph'
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
