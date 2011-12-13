require 'ostruct'
require 'petroglyph'

describe Petroglyph do

  it "renders to json" do
    template = Petroglyph::Template.new
    template.data = {:something => :borrowed}
    template.render.should eq('{"something":"borrowed"}')
  end

  it "takes a simple string value" do
    template = Petroglyph::Template.build do
      node :whatever, "nevermind"
    end

    template.data.should eq(:whatever => "nevermind")
  end

  it "merges in a hash" do
    t = Petroglyph::Template.build do
      tea = {:tea => {:temperature => 'hot', :type => 'wulong'}}
      merge tea
    end

    t.data.should eq({:tea => {:temperature => "hot", :type => 'wulong'}})
  end

  it "merges within a block" do
    template = Petroglyph::Template.build do
      node :whatever do
        merge(:stuff => {:no => :way})
      end
    end

    template.data.should eq({:whatever => {:stuff => {:no => :way}}})
  end

  it "handles sibling nodes" do
    template = Petroglyph::Template.build do
      node :whatever, "nevermind"
      node :stuff, "awesome"
    end

    template.data.should eq({:whatever => "nevermind", :stuff => "awesome"})
  end

  it "handles sibling nodes as blocks" do
    template = Petroglyph::Template.build do
      node :whatever, "nevermind"
      node :stuff do
        merge(:too => :cool)
      end
    end

    template.data.should eq({:whatever => "nevermind", :stuff => {:too => :cool}})
  end

  it "nests nodes" do
    template = Petroglyph::Template.build do
      node :whatever do
        node :stuff, "awesome"
      end
    end

    template.data.should eq({:whatever => {:stuff => 'awesome'}})
  end

  it "uses regular ruby" do
    t = Petroglyph::Template.build do

      node :drink do
        if false
          "cold"
        else
          node(:tea) do
            merge(:temperature => "hot".upcase)
          end
        end
      end

    end

    t.data.should eq({:drink => {:tea => {:temperature => "HOT"}}})
  end

  it "takes local variables" do
    template = Petroglyph::Template.build(:stuff => 'awesome') do
      node :whatever, stuff
    end

    template.data.should eq({:whatever => 'awesome'})
  end

  it "handles helper methods" do
    def stuff
      "awesome"
    end

    template = Petroglyph::Template.build do
      node :whatever, stuff
    end

    template.data.should eq({:whatever => 'awesome'})
  end

  it "lets local variables take precedence over helper methods" do
    def stuff
      "okay"
    end

    template = Petroglyph::Template.build(:stuff => 'awesome') do
      node :whatever, stuff
    end

    template.data.should eq({:whatever => 'awesome'})
  end

  it "evaluates objects" do
    hal = OpenStruct.new(:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk')

    template = Petroglyph::Template.build do
      node :hal => hal do
        attributes :name, :temperament
      end
    end

    template.data.should eq({:hal => {:name => 'HAL 9000', :temperament => 'psychotic'}})
  end

  it "evaluates hashes" do
    hal = {:name => 'HAL 9000', :temperament => 'psychotic', :garbage => 'junk'}

    template = Petroglyph::Template.build do
      node :hal => hal do
        attributes :name, :temperament
      end
    end

    template.data.should eq({:hal => {:name => 'HAL 9000', :temperament => 'psychotic'}})
  end

  it "operates on enumerables" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')
    coffee = OpenStruct.new(:type => 'coffee', :temperature => 'lukewarm')

    t = Petroglyph::Template.build(:drinks => [tea, coffee]) do
      collection :drinks => drinks do
        attributes :type, :temperature
      end
    end

    t.data.should eq({:drinks => [{:type => 'tea', :temperature => 'hot'}, {:type => 'coffee', :temperature => 'lukewarm'}]})
  end

  it "operates on enumerables with explicitly named items" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')
    coffee = OpenStruct.new(:type => 'coffee', :temperature => 'lukewarm')

    t = Petroglyph::Template.build(:drinks => [tea, coffee]) do
      collection :drinks => drinks do |drink|
        node :drink do
          node :type, drink.type
        end
        node :prep, "Make water #{drink.temperature}."
      end
    end

    t.data.should eq({:drinks => [{:drink => {:type => 'tea'}, :prep => "Make water hot."}, {:drink => {:type => 'coffee'}, :prep => "Make water lukewarm."}]})
  end

  it "can operate on object attributes within a node" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')
    coffee = OpenStruct.new(:type => 'coffee', :temperature => 'lukewarm')

    t = Petroglyph::Template.build(:drinks => [tea, coffee]) do
      collection :drinks => drinks do |drink|
        node :drink => drink do
          attributes :type
        end
        node :prep, "Make water #{drink.temperature}."
      end
    end

    t.data.should eq({:drinks => [{:drink => {:type => 'tea'}, :prep => "Make water hot."}, {:drink => {:type => 'coffee'}, :prep => "Make water lukewarm."}]})
  end

end
