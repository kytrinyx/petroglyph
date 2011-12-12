require 'ostruct'
require 'petroglyph/node'

class TestContext

  attr_accessor :data

  def self.test(locals = {}, &block)
    parent_context = eval "self", block.binding
    t = self.new
    node = Petroglyph::Node.new(parent_context, locals)
    node.instance_eval(&block)
    t.data = node.value
    t
  end
end

describe Petroglyph::Node do

  describe "a basic node" do
    let(:node) { Petroglyph::Node.new }

    it "takes a name and a value" do
      node.name = :whatever
      node.value = "some data"

      node.to_hash.should eq({:whatever => 'some data'})
    end

    it "merges in a complex value" do
      node.name = :whatever
      node.merge({:stuff => 'awesome'})

      node.to_hash.should eq({:whatever => {:stuff => 'awesome'}})
    end

    it "adds simple string nodes" do
      node.name = :whatever
      node.node :stuff, "awesome"

      node.to_hash.should eq({:whatever => {:stuff => 'awesome'}})
    end

    it "adds string nodes in a block" do
      node.name = :whatever
      node.node(:stuff) { "awesome" }

      node.to_hash.should eq({:whatever => {:stuff => 'awesome'}})
    end

    it "evaluates attributes on an object" do
      node.name = :ai
      node.object = OpenStruct.new(:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk')
      node.attributes(:name, :temperament)

      node.to_hash.should eq({:ai => {:name => 'HAL 9000', :temperament => 'psychotic'}})
    end

    it "evaluates attributes on a hash" do
      node.name = :ai
      node.object = {:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk'}
      node.attributes(:name, :temperament)

      node.to_hash.should eq({:ai => {:name => 'HAL 9000', :temperament => 'psychotic'}})
    end
  end

  context "within a block" do
    it "handles sibling nodes" do
      test = TestContext.test do
        node :whatever, "nevermind"
        node :stuff, "awesome"
      end

      test.data.should eq({:whatever => "nevermind", :stuff => "awesome"})
    end

    it "handles sibling nodes as blocks" do
      test = TestContext.test do
        node :whatever do
          "nevermind"
        end
        node :stuff do
          {:too => :cool}
        end
      end

      test.data.should eq({:whatever => "nevermind", :stuff => {:too => :cool}})
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

    it "lets local variables take precedence over helper methods" do
      def stuff
        "okay"
      end

      test = TestContext.test(:stuff => 'awesome') do
        node :whatever, stuff
      end

      test.data.should eq({:whatever => 'awesome'})
    end

    xit "nests nodes" do
      test = TestContext.test do
        node :whatever do
          node(:stuff) { "awesome" }
        end
      end

      test.data.should eq({:whatever => {:stuff => 'awesome'}})
    end
  end

end
