require 'tilt/petroglyph'

module Sinatra::Templates
  def pg(template, options={}, locals={})
    options.merge!(:default_content_type => :json)
    render :pg, template, options, locals
  end
end
