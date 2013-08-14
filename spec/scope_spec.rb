require 'spec_helper'

def fake_partial(s)
  eval "Proc.new{#{s}}"
end

describe Petroglyph::Scope do

  it 'takes a simple string value' do
    scope = Petroglyph::Scope.new
    scope.node :beverage => 'soda pop'
    scope.value.should eq(:beverage => 'soda pop')
  end

  it 'merges in a hash' do
    tea = {:tea => {:type => 'wulong', :temperature => 'hot'}}

    scope = Petroglyph::Scope.new
    scope.merge tea
    scope.value.should eq({:tea => {:type => 'wulong', :temperature => 'hot'}})
  end

  it 'merges within a block' do
    scope = Petroglyph::Scope.new
    scope.node :beverage do
      merge('espresso' => {:shots => 2})
    end

    scope.value.should eq({:beverage => {'espresso' => {:shots => 2}}})
  end




  context 'with an array' do
    let(:tea) { OpenStruct.new(:type => 'tea', :temperature => 'hot') }
    let(:coffee) { OpenStruct.new(:type => 'coffee', :temperature => 'warm') }
    let(:drinks) { [tea, coffee] }
    
    it 'merges array' do
      scope = Petroglyph::Scope.new
      scope.collection drinks do
        attributes :type, :temperature
      end

      scope.value.should eq([{:type => 'tea', :temperature => 'hot'}, {:type => 'coffee', :temperature => 'warm'}])
    end

    it 'evaluates attributes on explicitly named items' do
      scope = Petroglyph::Scope.new
      scope.collection drinks do |drink|
        node :drink do
          node :type => drink.type
        end
        node :prep => "Make water #{drink.temperature}."
      end

      scope.value.should eq([{:drink => {:type => 'tea'}, :prep => 'Make water hot.'}, {:drink => {:type => 'coffee'}, :prep => 'Make water warm.'}])
    end

    it 'evaluates object attributes within a sub node' do
      scope = Petroglyph::Scope.new
      scope.collection drinks do |drink|
        node :drink => drink do
          attributes :type
        end
        node :prep => "Water should be #{drink.temperature}."
      end

      scope.value.should eq([{:drink => {:type => 'tea'}, :prep => 'Water should be hot.'}, {:drink => {:type => 'coffee'}, :prep => 'Water should be warm.'}])
    end

    it 'evaluates an empty collection to an empty array' do
      scope = Petroglyph::Scope.new
      scope.collection [] do |drink|
        node :drink => drink
      end

      scope.value.should eq([])
    end

    it 'has a convenience handler' do
      Petroglyph.stub(:partial) { fake_partial('node :drink => drink.type') }

      scope = Petroglyph::Scope.new
      scope.collection drinks, :partial => :drink

      scope.value.should eq([{:drink => 'tea'}, {:drink => 'coffee'}])
    end
  end




  it 'lets you process what you merge in a block' do
    scope = Petroglyph::Scope.new
    drink = 'Zombie Driver'
    def drink.tagline
      'Take your mind off the apocalypse!'
    end
    scope.node :beverage do
      merge(drink) do
        attributes :tagline
      end
    end

    scope.value.should eq({:beverage => {:tagline => 'Take your mind off the apocalypse!'}})
  end

  it 'handles sibling nodes' do
    scope = Petroglyph::Scope.new
    scope.node :beverage => 'bubble milk tea'
    scope.node :price => 2.5

    scope.value.should eq({:beverage => 'bubble milk tea', :price => 2.5})
  end

  it 'handles sibling nodes as blocks' do
    scope = Petroglyph::Scope.new
    scope.node :beverage => 'root beer float'
    scope.node :ingredients do
      merge(:ice_cream => 'vanilla', :root_beer => 'to taste')
    end

    scope.value.should eq({:beverage => 'root beer float', :ingredients => {:ice_cream => 'vanilla', :root_beer => 'to taste'}})
  end

  it 'nests nodes' do
    scope = Petroglyph::Scope.new
    scope.node :beverage do
      node :tea => 'black'
    end

    scope.value.should eq({:beverage => {:tea => 'black'}})
  end

  it 'nests stuff arbitrarily deeply with complex values' do
    scope = Petroglyph::Scope.new
    scope.node :drink do
      node :tea do
        node :temperature do
          merge(:really => 'hot')
        end
      end
    end

    scope.value.should eq({:drink => {:tea => {:temperature => {:really => 'hot'}}}})
  end

  it 'uses regular ruby' do
    scope = Petroglyph::Scope.new
    scope.node :beverage do
      if false
        'hot'
      else
        node(:tea) do
          merge(:temperature => 'iced'.upcase)
        end
      end
    end

    scope.value.should eq({:beverage => {:tea => {:temperature => 'ICED'}}})
  end

  context 'with locals' do
    let(:scope) { Petroglyph::Scope.new(nil, {:drink => 'strawberry daikiri'}) }

    before(:each) do
      scope.instance_eval do
        node :beverage => drink
      end
    end

    it 'resolves values' do
      scope.value.should eq({:beverage => 'strawberry daikiri'})
    end

    it 'responds to existing locals' do
      scope.respond_to?(:drink).should == true
    end

    it "doesn't respond to missing locals" do
      scope.respond_to?(:not_a_thing).should == false
    end

    it "doesn't clobber :respond_to? for existing methods" do
      scope.respond_to?(:value).should == true
    end
  end

  describe 'within a context' do
    it 'has access to methods' do
      context = Object.new
      def context.drink
        'tisane'
      end

      scope = Petroglyph::Scope.new(context)
      scope.instance_eval do
        node :beverage => drink
      end
      scope.value.should eq({:beverage => 'tisane'})
    end

    it 'lets local variables take precedence over methods' do
      context = Object.new
      def context.drink
        'coffee'
      end

      scope = Petroglyph::Scope.new(context, {:drink => 'rooiboos tea'})
      scope.instance_eval do
        node :beverage => drink
      end
      scope.value.should eq({:beverage => 'rooiboos tea'})
    end
  end

  describe 'attributes' do
    it 'evaluates on an object' do
      drink = OpenStruct.new(:name => "Grandma's Herb Garden", :temperature => 'luke warm', :origin => 'the garden')

      scope = Petroglyph::Scope.new
      scope.node :beverage => drink do
        attributes :name, :temperature
      end

      scope.value.should eq({:beverage => {:name => "Grandma's Herb Garden", :temperature => 'luke warm'}})
    end

    it 'evaluates on a hash' do
      drink = {:name => 'darjeeling', :temperature => 'piping hot', :origin => 'the store'}

      scope = Petroglyph::Scope.new
      scope.node :beverage => drink do
        attributes :name, :temperature
      end

      scope.value.should eq({:beverage => {:name => 'darjeeling', :temperature => 'piping hot'}})
    end
  end


  context 'with a collection' do
    let(:tea) { OpenStruct.new(:type => 'tea', :temperature => 'hot') }
    let(:coffee) { OpenStruct.new(:type => 'coffee', :temperature => 'warm') }
    let(:drinks) { [tea, coffee] }

    it 'evaluates attributes' do
      scope = Petroglyph::Scope.new
      scope.collection :beverages => drinks do
        attributes :type, :temperature
      end

      scope.value.should eq({:beverages => [{:type => 'tea', :temperature => 'hot'}, {:type => 'coffee', :temperature => 'warm'}]})
    end

    it 'evaluates attributes on explicitly named items' do
      scope = Petroglyph::Scope.new
      scope.collection :beverages => drinks do |drink|
        node :drink do
          node :type => drink.type
        end
        node :prep => "Make water #{drink.temperature}."
      end

      scope.value.should eq({:beverages => [{:drink => {:type => 'tea'}, :prep => 'Make water hot.'}, {:drink => {:type => 'coffee'}, :prep => 'Make water warm.'}]})
    end

    it 'evaluates object attributes within a sub node' do
      scope = Petroglyph::Scope.new
      scope.collection :beverages => drinks do |drink|
        node :drink => drink do
          attributes :type
        end
        node :prep => "Water should be #{drink.temperature}."
      end

      scope.value.should eq({:beverages => [{:drink => {:type => 'tea'}, :prep => 'Water should be hot.'}, {:drink => {:type => 'coffee'}, :prep => 'Water should be warm.'}]})
    end

    it 'evaluates an empty collection to an empty array' do
      scope = Petroglyph::Scope.new
      scope.collection :beverages => [] do |drink|
        node :drink => drink
      end

      scope.value.should eq({:beverages => []})
    end

    it 'has a convenience handler' do
      Petroglyph.stub(:partial) { fake_partial('node :drink => drink.type') }

      scope = Petroglyph::Scope.new
      scope.collection :drinks => drinks, :partial => :drink

      scope.value.should eq({:drinks => [{:drink => 'tea'}, {:drink => 'coffee'}]})
    end
  end

  context 'with partials' do
    it 'renders a partial' do
      Petroglyph.stub(:partial) { fake_partial('node :drink => "tea"') }

      scope = Petroglyph::Scope.new
      scope.node :partial do
        partial :the_partial
      end

      scope.value.should eq({:partial => {:drink => 'tea'}})
    end

    it 'renders a partial with local variables' do
      Petroglyph.stub(:partial) { fake_partial('node :drink => drink') }

      scope = Petroglyph::Scope.new
      scope.node :partial do
        partial :the_partial, :drink => 'tea'
      end

      scope.value.should eq({:partial => {:drink => 'tea'}})
    end

    it 'defaults locals to match the name of the partial' do
      Petroglyph.stub(:partial) { fake_partial('node :beverage => drink') }

      scope = Petroglyph::Scope.new(nil, {:drink => 'coffee'})
      scope.node :beverages do
        partial :drink
      end

      scope.value.should eq({:beverages => {:beverage => 'coffee'}})
    end

    it 'finds the partial' do
      scope = Petroglyph::Scope.new
      # Pretend that this node is defined in some_template
      # so that we have a decent relative path for the partial.
      scope.file = 'spec/fixtures/views/some_template.pg'
      scope.node :partial do
        partial :the_partial, :drink => 'mocha'
      end

      scope.value.should eq({:partial => {:beverage => 'mocha'}})
    end

    it 'finds the partial in a subdirectory' do
      scope = Petroglyph::Scope.new
      scope.file = 'spec/fixtures/views/some_template.pg'
      scope.node :partial do
        partial :sub_partial, :thing => 'stuff'
      end

      scope.value.should eq({:partial => {:thing => 'stuff'}})
    end

    it 'finds nested partials' do
      scope = Petroglyph::Scope.new
      scope.file = 'spec/fixtures/views/some_template.pg'

      scope.node :partial do
        partial :nested_partial
      end

      scope.value.should eq({:partial => {:beverage => 'stuff'}})
    end
  end
end
