require 'spec_helper'
require 'sinatra'
require 'sinatra/petroglyph'
require 'rack/test'

class PetroglyphApp < Sinatra::Base
  set :root, File.dirname(__FILE__)+"/fixtures"
  set :show_exceptions, false

  get "/" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')
    coffee = OpenStruct.new(:type => 'coffee', :temperature => 'lukewarm')
    pg :index, :locals => {:drinks => [tea, coffee]}
  end

  post '/' do
    pg :post, :locals => {:post => 'a post'}
  end
end

describe "Sinatra integration" do
  include Rack::Test::Methods

  def app
    PetroglyphApp
  end

  it "works" do
    get "/"
    last_response.body.should eq '{"drinks":[{"type":"tea","temperature":"hot"},{"type":"coffee","temperature":"lukewarm"}]}'
  end

  xit "doesn't freak out on the HTTP method" do
    post '/'
    last_response.body.should eq '{}'
  end
end
