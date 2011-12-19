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

  context "with a context" do
    it "evaluates instance variables" do
      context = Object.new
      context.instance_eval { @thing = 'stuff' }

      engine = Petroglyph::Engine.new('node :whatever => @thing')
      engine.render(context).should eq({:whatever => 'stuff'}.to_json)
    end

    it "evaluates methods" do
      context = Object.new
      def context.thing
        "stuff"
      end

      engine = Petroglyph::Engine.new('node :whatever => thing')
      engine.render(context).should eq({:whatever => 'stuff'}.to_json)
    end

    it "doesn't freak out if the method raises an exception" do
      context = Object.new
      context = Object.new
      def context.thing
        raise Exception.new('Freaking out')
      end

      engine = Petroglyph::Engine.new('node :whatever => thing')
      engine.render(context, {:thing => 'stuff'}).should eq({:whatever => 'stuff'}.to_json)
    end
  end

  it "passes the locals" do
    engine = Petroglyph::Engine.new('node :whatever => thing')
    engine.render(nil, {:thing => 'stuff'}).should eq({:whatever => 'stuff'}.to_json)
  end

end
