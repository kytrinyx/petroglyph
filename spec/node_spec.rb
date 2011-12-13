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

  context "within a block" do
    it "takes a simple string value" do
      test = TestContext.test do
        node :whatever, "nevermind"
      end

      test.data.should eq({:whatever => "nevermind"})
    end

    it "can merge in a block" do
      test = TestContext.test do
        node :whatever do
          merge(:stuff => {:no => :way})
        end
      end

      test.data.should eq({:whatever => {:stuff => {:no => :way}}})
    end

    it "handles sibling nodes" do
      test = TestContext.test do
        node :whatever, "nevermind"
        node :stuff, "awesome"
      end

      test.data.should eq({:whatever => "nevermind", :stuff => "awesome"})
    end

    it "handles sibling nodes as blocks" do
      test = TestContext.test do
        node :whatever, "nevermind"
        node :stuff do
          merge(:too => :cool)
        end
      end

      test.data.should eq({:whatever => "nevermind", :stuff => {:too => :cool}})
    end

    it "nests nodes" do
      test = TestContext.test do
        node :whatever do
          node :stuff, "awesome"
        end
      end

      test.data.should eq({:whatever => {:stuff => 'awesome'}})
    end

    it "takes local variables" do
      test = TestContext.test(:stuff => 'awesome') do
        node :whatever, stuff
      end

      test.data.should eq({:whatever => 'awesome'})
    end

    it "handles helper methods" do
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

    it "evaluates objects" do
      hal = OpenStruct.new(:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk')

      test = TestContext.test do
        node :hal => hal do
          attributes :name, :temperament
        end
      end

      test.data.should eq({:hal => {:name => 'HAL 9000', :temperament => 'psychotic'}})
    end

    it "evaluates hashes" do
      hal = {:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk'}

      test = TestContext.test do
        node :hal => hal do
          attributes :name, :temperament
        end
      end

      test.data.should eq({:hal => {:name => 'HAL 9000', :temperament => 'psychotic'}})
    end
  end

end
