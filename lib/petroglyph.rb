require 'json'

require 'petroglyph/scope'
require 'petroglyph/engine'

module Petroglyph
  class << self
    def partial(filename, template_filename)
      basedir = File.dirname(template_filename)
      [basedir, "#{basedir}/partials"].each do |dir|
        path = File.join(dir, "#{filename}.pg")
        return File.read(path) if File.exist?(path)
      end
      raise Exception.new("Could not find partial #{filename}")
    end
  end
end

if defined?(Padrino)
  require 'padrino-core'
  Padrino.after_load do
    require 'petroglyph/template'
  end
elsif defined?(Rails) && Rails.version =~ /^2/
  require 'petroglyph/template'
elsif defined?(Rails) && Rails.version =~ /^3/
  require 'petroglyph/railtie'
end
