# Petroglyph

A simple ruby dsl to create json views.

## Examples

Add a node with a simple value:

    node :beverage, current_user.favorite_drink
    => '{"beverage":"mead"}'

This can also be done with the normal hash syntax:

    self[:beverage] = current_user.favorite_drink
    => '{"beverage":"mead"}'

Add a node with nested content:

    node :home do
      merge {:location => {:city => 'Paris', :country => 'France'}}
    end
    => '{"home":{"location":{"city":"Paris","country":"France"}}}'

Add sibling nodes within a node:

    node :pet do
      merge {:species => "turtle", :color => 'green'}
      self[:name] = "Anthony"
    end
    => '{"pet":{"species":"turtle","color":"green","name":"Anthony"}}'

It's all just ruby, unsurprisingly:

    node :pet do
      if user.child?
        merge {:species => "turtle", :color => 'green'}
        self[:name] = "Anthony"
      else
        node :species, 'human'
        node :name, 'Billy'
      end
    end
    => '{"pet":{"species":"turtle","name":"Anthony"}}'

Conveniently define which attributes to include

    alice = Person.create!(:name => 'Alice', :profession => 'surgeon', :created_at => 28.years.ago, :gender => 'female')

    node :person => alice do |name|
      attributes :name, :profession, :gender
    end
    => '{"person":{"name":"Alice","profession":"surgeon","gender":"female"}}'

Iterate through collections:

    wulong = Tea.new(:type => 'wulong')
    lucha = Tea.new(:type => 'green')

    collection :teas => [wulong, green] do
      attributes :type
    end
    => '{"teas":[{"type":"wulong"},{"type":"wulong"}]}'


You can also explicitly reference each item in the collection if you need to:

    collection :teas => teas do |tea|
      attributes :type

      node :provider, lookup_provider_for(tea)
    end
    => '{"teas":[{"type":"wulong","provider":"Imperial Teas"},{"type":"wulong","provider":"House of Tea"}]}'

