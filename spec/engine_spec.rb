require 'spec_helper'

describe Petroglyph::Engine do
  it "takes a template" do
    engine = Petroglyph::Engine.new('node :whatever => "nevermind"')
    engine.render.should eq({:whatever => "nevermind"}.to_json)
  end

  it "takes a block" do
    Petroglyph::Engine.new.render do
      node :whatever => "nevermind"
    end.should eq({:whatever => "nevermind"}.to_json)
  end

  it "passes the locals" do
    engine = Petroglyph::Engine.new('node :whatever => thing')
    engine.render(nil, {:thing => 'stuff'}).should eq({:whatever => 'stuff'}.to_json)
  end
end
