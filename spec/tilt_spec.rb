require 'spec_helper'
require 'tilt/petroglyph'

describe "Tilt integration" do
  it "registers .pg as a petroglyph template" do
    Tilt.mappings['pg'].should include(Tilt::PetroglyphTemplate)
  end

  it "renders from a file" do
    template = Tilt::PetroglyphTemplate.new('spec/fixtures/views/syntax.pg')
    template.render.should eq('{"syntax":{"it":"works"}}')
  end

  it "renders from a block" do
    template = Tilt::PetroglyphTemplate.new { |t| 'node :hello => "world"' }
    template.render.should eq("{\"hello\":\"world\"}")
  end

  it "can be rendered more than once" do
    template = Tilt::PetroglyphTemplate.new { |t| 'node :hello => "world"' }

    3.times do
      template.render.should eq("{\"hello\":\"world\"}")
    end
  end

  it "takes local variables" do
    template = Tilt::PetroglyphTemplate.new { |t| 'node :hello => place' }
    template.render(Object.new, :place => 'world').should eq("{\"hello\":\"world\"}")
  end

  context "with partials" do
    it "loads the partial" do
      template = Tilt::PetroglyphTemplate.new('spec/fixtures/views/with_partial.pg')
      template.render.should eq('{"root":{"beverage":"stuff"}}')
    end

    it "loads the partial from a subdirectory" do
      template = Tilt::PetroglyphTemplate.new('spec/fixtures/views/with_sub_partial.pg')
      template.render.should eq('{"root":{"thing":"stuff"}}')
    end

  end
end
