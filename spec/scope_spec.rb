require 'spec_helper'

describe Petroglyph::Scope do

  it "takes a simple string value" do
    scope = Petroglyph::Scope.new
    scope.node :whatever => "nevermind"
    scope.value.should eq(:whatever => "nevermind")
  end

  it "merges in a hash" do
    tea = {:tea => {:temperature => 'hot', :type => 'wulong'}}

    scope = Petroglyph::Scope.new
    scope.merge tea
    scope.value.should eq({:tea => {:temperature => "hot", :type => 'wulong'}})
  end

  it "merges within a block" do
    scope = Petroglyph::Scope.new
    scope.node :whatever do
      merge(:stuff => {:no => :way})
    end

    scope.value.should eq({:whatever => {:stuff => {:no => :way}}})
  end

  it "lets you process what you merge in a block" do
    scope = Petroglyph::Scope.new
    scope.node :whatever do
      merge(10) do
        attributes :to_s
      end
    end

    scope.value.should eq({:whatever => {:to_s => '10'}})
  end

  it "handles sibling nodes" do
    scope = Petroglyph::Scope.new
    scope.node :whatever => "nevermind"
    scope.node :stuff => "awesome"

    scope.value.should eq({:whatever => "nevermind", :stuff => "awesome"})
  end

  it "handles sibling nodes as blocks" do
    scope = Petroglyph::Scope.new
    scope.node :whatever => "nevermind"
    scope.node :stuff do
      merge(:too => :cool)
    end

    scope.value.should eq({:whatever => "nevermind", :stuff => {:too => :cool}})
  end

  it "nests nodes" do
    scope = Petroglyph::Scope.new
    scope.node :whatever do
      node :stuff => "awesome"
    end

    scope.value.should eq({:whatever => {:stuff => 'awesome'}})
  end

  it "nests stuff arbitrarily deeply with complex values" do
    scope = Petroglyph::Scope.new
    scope.node :drink do
      node :tea do
        node :temperature do
          merge(:really => :hot)
        end
      end
    end

    scope.value.should eq({:drink => {:tea => {:temperature => {:really => :hot}}}})
  end

  it "uses regular ruby" do
    scope = Petroglyph::Scope.new
    scope.node :drink do
      if false
        "cold"
      else
        node(:tea) do
          merge(:temperature => "hot".upcase)
        end
      end
    end

    scope.value.should eq({:drink => {:tea => {:temperature => "HOT"}}})
  end

  context "with locals" do
    let(:scope) { Petroglyph::Scope.new(nil, {:thing => 'stuff'}) }

    before(:each) do
      scope.instance_eval do
        node :thing => thing
      end
    end

    it "resolves values" do
      scope.value.should eq({:thing => 'stuff'})
    end

    it "responds to existing locals" do
      scope.respond_to?(:thing).should == true
    end

    it "doesn't respond to missing locals" do
      scope.respond_to?(:not_a_thing).should == false
    end

    it "doesn't clobber :respond_to?" do
      scope.respond_to?(:value).should == true
    end
  end

  describe "within a context" do
    it "has access to methods" do
      context = Object.new
      def context.thing
        'stuff'
      end

      scope = Petroglyph::Scope.new(context)
      scope.instance_eval do
        node :thing => thing
      end
      scope.value.should eq({:thing => 'stuff'})
    end

    it "lets local variables take precedence over methods" do
      context = Object.new
      def context.thing
        'junk'
      end

      scope = Petroglyph::Scope.new(context, {:thing => 'stuff'})
      scope.instance_eval do
        node :thing => thing
      end
      scope.value.should eq({:thing => 'stuff'})
    end
  end

  describe "attributes" do
    it "evaluates on an object" do
      hal = OpenStruct.new(:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk')

      scope = Petroglyph::Scope.new
      scope.node :hal => hal do
        attributes :name, :temperament
      end

      scope.value.should eq({:hal => {:name => 'HAL 9000', :temperament => 'psychotic'}})
    end

    it "evaluates on a hash" do
      hal = {:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk'}

      scope = Petroglyph::Scope.new
      scope.node :hal => hal do
        attributes :name, :temperament
      end

      scope.value.should eq({:hal => {:name => 'HAL 9000', :temperament => 'psychotic'}})
    end
  end

  context "with a collection" do
    let(:tea) { OpenStruct.new(:type => 'tea', :temperature => 'hot') }
    let(:coffee) { OpenStruct.new(:type => 'coffee', :temperature => 'lukewarm') }
    let(:drinks) { [tea, coffee] }

    it "evaluates attributes" do
      scope = Petroglyph::Scope.new
      scope.collection :drinks => drinks do
        attributes :type, :temperature
      end

      scope.value.should eq({:drinks => [{:type => 'tea', :temperature => 'hot'}, {:type => 'coffee', :temperature => 'lukewarm'}]})
    end

    it "evaluates attributes on explicitly named items" do
      scope = Petroglyph::Scope.new
      scope.collection :drinks => drinks do |drink|
        node :drink do
          node :type => drink.type
        end
        node :prep => "Make water #{drink.temperature}."
      end

      scope.value.should eq({:drinks => [{:drink => {:type => 'tea'}, :prep => "Make water hot."}, {:drink => {:type => 'coffee'}, :prep => "Make water lukewarm."}]})
    end

    it "evaluates object attributes within a sub node" do
      scope = Petroglyph::Scope.new
      scope.collection :drinks => drinks do |drink|
        node :drink => drink do
          attributes :type
        end
        node :prep => "Make water #{drink.temperature}."
      end

      scope.value.should eq({:drinks => [{:drink => {:type => 'tea'}, :prep => "Make water hot."}, {:drink => {:type => 'coffee'}, :prep => "Make water lukewarm."}]})
    end

    it "evaluates an empty collection to an empty array" do
      scope = Petroglyph::Scope.new
      scope.collection :drinks => [] do |drink|
        node :drink => drink
      end

      scope.value.should eq({:drinks => []})
    end
  end

  context "with partials" do
    it "renders a partial" do
      Petroglyph.stub(:partial) { 'node :drink => "tea"' }

      scope = Petroglyph::Scope.new
      scope.node :partial do
        partial :the_partial
      end

      scope.value.should eq({:partial => {:drink => 'tea'}})
    end

    it "renders a partial with local variables" do
      Petroglyph.stub(:partial) { 'node :drink => drink' }

      scope = Petroglyph::Scope.new
      scope.node :partial do
        partial :the_partial, :drink => 'tea'
      end

      scope.value.should eq({:partial => {:drink => 'tea'}})
    end

    it "defaults locals to match the name of the partial" do
      Petroglyph.stub(:partial) { 'node :drink => drink' }

      scope = Petroglyph::Scope.new(nil, {:drink => 'coffee'})
      scope.node :drinks do
        partial :drink
      end

      scope.value.should eq({:drinks => {:drink => 'coffee'}})
    end

    it "finds the partial" do
      scope = Petroglyph::Scope.new
      scope.file = "spec/fixtures/views/some_template.pg"
      scope.node :partial do
        partial :the_partial, :thing => 'stuff'
      end

      scope.value.should eq({:partial => {:thing => 'stuff'}})
    end

    it "finds the partial in a subdirectory" do
      scope = Petroglyph::Scope.new
      scope.file = "spec/fixtures/views/some_template.pg"
      scope.node :partial do
        partial :sub_partial, :thing => 'stuff'
      end

      scope.value.should eq({:partial => {:thing => 'stuff'}})
    end

    it "finds nested partials" do
      scope = Petroglyph::Scope.new
      scope.file = "spec/fixtures/views/some_template.pg"

      scope.node :partial do
        partial :nested_partial
      end

      scope.value.should eq({:partial => {:thing => 'stuff'}})
    end
  end
end
