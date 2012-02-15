module Petroglyph
  class Railtie < Rails::Railtie

    initializer "petroglyph.initialize" do |app|
      ActiveSupport.on_load(:action_view) do
        Petroglyph.register!
      end
    end
  end
end