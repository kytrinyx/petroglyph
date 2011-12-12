require 'ostruct'
require 'petroglyph/node'

class TestContext

  attr_accessor :data

  def self.test(locals = {}, &block)
    parent_context = eval "self", block.binding
    t = self.new
    t.data = Petroglyph::Node.new(parent_context, locals).instance_eval(&block)
    t
  end
end

describe Petroglyph::Node do

  it "resolves to a hash given a name and a simple value" do
    node = Petroglyph::Node.new
    node.name = :whatever
    node.value = "some data"

    node.to_hash.should eq({:whatever => 'some data'})
  end

  it "merges in a complex value" do
    node = Petroglyph::Node.new
    node.name = :whatever
    node.merge({:stuff => 'awesome'})

    node.to_hash.should eq({:whatever => {:stuff => 'awesome'}})
  end

  it "has nodes" do
    node = Petroglyph::Node.new
    node.name = :whatever
    node.node :stuff, "awesome"

    node.to_hash.should eq({:whatever => {:stuff => 'awesome'}})
  end

  it "evaluates attributes on an object" do
    node = Petroglyph::Node.new
    node.name = :ai
    node.object = OpenStruct.new(:name => 'HAL 9000', :temperament => 'psychotic')
    node.attributes(:name, :temperament)

    node.to_hash.should eq({:ai => {:name => 'HAL 9000', :temperament => 'psychotic'}})
  end

  xit "nests nodes" do
    test = TestContext.test do
      node :whatever do
        node :stuff do
          node :finally, "awesome"
        end
      end
    end

    test.data.should eq({:whatever => {:stuff => {:finally => 'awesome'}}})
  end

  it "handles siblings" do
    test = TestContext.test do
      node :whatever, "nevermind"
      node :stuff, "awesome"
    end

    test.data.should eq({:whatever => "nevermind", :stuff => "awesome"})
  end

  it "handles other siblings" do
    test = TestContext.test do
      node :whatever do
        "nevermind"
      end
      node :stuff do
        "awesome"
      end
    end

    test.data.should eq({:whatever => "nevermind", :stuff => "awesome"})
  end

  it "takes local variables" do
    test = TestContext.test(:stuff => 'awesome') do
      node :whatever, stuff
    end

    test.data.should eq({:whatever => 'awesome'})
  end

  it "can handle helper methods" do
    def stuff
      "awesome"
    end

    test = TestContext.test do
      node :whatever, stuff
    end

    test.data.should eq({:whatever => 'awesome'})
  end

  xit "lets local variables take precedence over helper methods" do
    def stuff
      "okay"
    end

    test = TestContext.test(:stuff => 'awesome') do
      node :whatever, stuff
    end

    test.data.should eq({:whatever => 'awesome'})
  end
end
