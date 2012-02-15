module Petroglyph
  class Railtie < Rails::Railtie

    initializer "petroglyph.initialize" do |app|
      ActiveSupport.on_load(:action_view) do
        require 'petroglyph/template'
      end
    end
  end
end
