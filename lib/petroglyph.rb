require 'json'

require 'petroglyph/scope'
require 'petroglyph/engine'

module Petroglyph
  class << self

    def partial(filename, template_filename)
      @partials ||= {}
      path = full_path(filename, template_filename)

      unless path
        raise Exception.new("Could not find partial #{filename}")
      end

      @partials.fetch(path) { eval "Proc.new{#{File.read(path)}}" }
    end

    def full_path(filename, template_filename)
      @paths ||= {}
      key = "#{template_filename}:#{filename}"

      return @paths[key] if @paths.has_key?(key)

      basedir = File.dirname(template_filename)
      [basedir, "#{basedir}/partials"].each do |dir|
        path = File.join(dir, "#{filename}.pg")
        return path if File.exist?(path)
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
