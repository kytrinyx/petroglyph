require 'petroglyph'

describe Petroglyph do
  it "evaluates a template" do
    Petroglyph.compile('node :hello => "world"').should eq('{"hello":"world"}')
  end

  it "evaluates a template from a block" do
    Petroglyph.compile do
      node :hello => "world"
    end.should eq('{"hello":"world"}')
  end

  it "evaluates a template with local variables" do
    Petroglyph.compile('node :hello => place', :place => 'world').should eq('{"hello":"world"}')
  end
end
