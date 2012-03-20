module Petroglyph
  class Railtie < Rails::Railtie

    initializer "petroglyph.initialize" do |app|
      ActiveSupport.on_load(:action_view) do
        require 'rails/3.x/petroglyph'
      end
    end
  end
end
