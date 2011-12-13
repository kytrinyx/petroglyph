# Petroglyph

A simple ruby dsl to create json views.

## Examples

Add a node with a simple value:

    node :beverage, current_user.favorite_drink
    => '{"beverage":"mead"}'

Add a node with nested content:

    node :home do
      merge {:location => {:city => 'Paris', :country => 'France'}}
    end
    => '{"home":{"location":{"city":"Paris","country":"France"}}}'

Add sibling nodes within a node:

    node :pet do
      merge {:species => "turtle", :color => 'green'}
      node :name, "Anthony"
    end
    => '{"pet":{"species":"turtle","color":"green","name":"Anthony"}}'

It's all just ruby, unsurprisingly:

    node :pet do
      if user.child?
        merge {:species => "turtle"}
        node :name, "Anthony"
      else
        node :species, 'human'
        node :name, 'Billy'
      end
    end
    => '{"pet":{"species":"turtle","name":"Anthony"}}'

Conveniently define which attributes to include. Create a new node with a different name for attributes you wish to alias.

    alice = Person.create!(:name => 'Alice', :profession => 'surgeon', :created_at => 28.years.ago, :gender => 'female')

    node :person => alice do
      attributes :name, :gender
      node :job, alice.profession
    end
    => '{"person":{"name":"Alice","gender":"female","job":"surgeon"}}'

Iterate through collections:

    wulong = Tea.new(:type => 'wulong')
    lucha = Tea.new(:type => 'green')

    collection :teas => [wulong, green] do
      attributes :type
    end
    => '{"teas":[{"type":"wulong"},{"type":"wulong"}]}'


You can also explicitly reference each item in the collection if you need to:

    collection :teas => teas do |tea|
      node :tea => tea do
        attributes :type
      end
      node :provider, lookup_provider_for(tea)
    end
    => '{"teas":[{"tea":{"type":"wulong"},{"provider":"Imperial Teas"}},{"tea":{"type":"wulong"},{"provider":"House of Tea"}}]}'

