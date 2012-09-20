require 'spec_helper'

describe Petroglyph::Engine do
  specify "#to_hash" do
    engine = Petroglyph::Engine.new('node :beverage => drink')
    engine.to_hash({:drink => 'espresso'}).should eq({:beverage => 'espresso'})
  end

  it "takes a template" do
    engine = Petroglyph::Engine.new('node :beverage => "no, thanks"')
    engine.render.should eq({:beverage => "no, thanks"}.to_json)
  end

  it "takes a block" do
    Petroglyph::Engine.new.render do
      node :beverage => "hot chocolate"
    end.should eq({:beverage => "hot chocolate"}.to_json)
  end

  it "passes the locals" do
    engine = Petroglyph::Engine.new('node :beverage => drink')
    engine.render(nil, {:drink => 'bai mu cha'}).should eq({:beverage => 'bai mu cha'}.to_json)
  end
end
