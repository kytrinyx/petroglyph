require 'ostruct'
require 'petroglyph'

describe Petroglyph do

  it "adds a node with a simple value" do
    t = Petroglyph::Template.build do
      node :drink, "tea"
    end

    t.render.should eq({:drink => "tea"}.to_json)
  end

  it "adds a node with a string in a block" do
    t = Petroglyph::Template.build do
      node(:drink) { "tea" }
    end

    t.render.should eq({:drink => "tea"}.to_json)
  end

  it "nests stuff arbitrarily deeply" do
    t = Petroglyph::Template.build do
      node :drink do
        node :tea do
          node :temperature do
            "hot"
          end
        end
      end
    end

    t.render.should eq({:drink => {:tea => {:temperature => "hot"}}}.to_json)
  end

  it "nests stuff arbitrarily deeply with complex values" do
    t = Petroglyph::Template.build do
      node :drink do
        node :tea do
          node :temperature do
            {:really => :hot}
          end
        end
      end
    end

    t.render.should eq({:drink => {:tea => {:temperature => {:really => :hot}}}}.to_json)
  end

  it "uses regular ruby" do
    t = Petroglyph::Template.build do

      node :drink do
        if false
          "cold"
        else
          node(:tea) { "hot".upcase }
        end
      end

    end

    t.render.should eq({:drink => {:tea => "HOT"}}.to_json)
  end

  it "merges in a hash" do
    t = Petroglyph::Template.build do
      tea = {:tea => {:temperature => 'hot', :type => 'wulong'}}
      merge tea
    end

    t.render.should eq({:tea => {:temperature => "hot", :type => 'wulong'}}.to_json)
  end

  it "takes local variables" do
    t = Petroglyph::Template.build(:temperature => 'hot') do
      node :tea do
        node(:temperature) { temperature }
      end
    end

    t.render.should eq({:tea => {:temperature => "hot"}}.to_json)
  end

  it "can handle helper methods" do
    def temperature
      "hot"
    end

    t = Petroglyph::Template.build do
      node :tea do
        node(:temperature) { temperature }
      end
    end

    t.render.should eq({:tea => {:temperature => "hot"}}.to_json)
  end

  it "lets local variables take precedence over helper methods" do
    def temperature
      "warm"
    end

    t = Petroglyph::Template.build(:temperature => 'hot') do
      node :tea do
        node(:temperature) { temperature }
      end
    end

    t.render.should eq({:tea => {:temperature => "hot"}}.to_json)
  end

  it "makes sibling nodes" do
    t = Petroglyph::Template.build do
      node :drink, "tea"
      node :type, "wulong"
    end

    t.render.should eq({:drink => "tea", :type => "wulong"}.to_json)
  end

  it "makes sibling nodes using blocks" do
    t = Petroglyph::Template.build do
      node :drink do
        "tea"
      end
      node :type do
        "wulong"
      end
    end

    t.render.should eq({:drink => "tea", :type => "wulong"}.to_json)
  end

  it "operates on objects" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')

    t = Petroglyph::Template.build(:drink => tea) do
      node :drink => drink do
        attributes :type, :temperature
      end
    end

    t.render.should eq({:drink => {:type => 'tea', :temperature => 'hot'}}.to_json)
  end

  it "operates on enumerables" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')

    t = Petroglyph::Template.build(:drinks => [tea]) do
      collection :drinks => drinks do
        attributes :type, :temperature
      end
    end

    t.render.should eq({:drinks => [{:type => 'tea', :temperature => 'hot'}]}.to_json)
  end

  xit "operates intelligently on enumerables" do
    tea = OpenStruct.new(:type => 'tea', :temperature => 'hot')

    t = Petroglyph::Template.build(:drinks => [tea]) do
      collection :drinks => drinks do
        node :drink do
          attributes :type, :temperature
        end
        node :preparation do
          "Boil water, then wait."
        end
      end
    end

    t.render.should eq({:drinks => [{:drink => {:type => 'tea', :temperature => 'hot'}, :preparation => 'Boil water, then wait.'}]}.to_json)
  end

  xit "can use self to add a node with a simple value" do
    t = Petroglyph::Template.build do
      self[:drink] = "tea"
    end

    t.render.should eq({:drink => "tea"}.to_json)
  end

end
