require 'json'

require 'petroglyph/scope'
require 'petroglyph/engine'

module Petroglyph
  class << self
    def partial(filename, template_filename)
      paths(filename, template_filename).each do |path|
        if File.exist?(path)
          return eval "Proc.new{#{File.read(path)}}"
        end
      end
      raise Exception.new("Could not find partial #{filename}")
    end

    def paths(filename, template_filename)
      basedir = File.dirname(template_filename)
      [basedir, "#{basedir}/partials"].map do |dir|
        File.join(dir, "#{filename}.pg")
      end
    end
  end
end

if defined? Padrino
  require 'padrino/petroglyph'
elsif defined? Sinatra
  require 'sinatra/petroglyph'
elsif defined?(Rails) && Rails.version =~ /^2/
  require 'rails/2.x/petroglyph'
elsif defined?(Rails) && Rails.version =~ /^3/
  require 'petroglyph/railtie'
end
