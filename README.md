# Petroglyph

A simple, terse, and unsurprising ruby dsl to create json views.

## Usage

Add a node with a simple value:

    node :beverage => current_user.favorite_drink
    => '{"beverage":"mead"}'

Add a node with nested content:

    node :home do
      merge {:location => {:city => 'Paris', :country => 'France'}}
    end
    => '{"home":{"location":{"city":"Paris","country":"France"}}}'

Add sibling nodes within a node:

    node :pet do
      merge {:species => "turtle", :color => 'green'}
      node :name => "Anthony"
    end
    => '{"pet":{"species":"turtle","color":"green","name":"Anthony"}}'

It's all just ruby, unsurprisingly:

    node :pet do
      if user.child?
        merge {:species => "turtle"}
        node :name => "Anthony"
      else
        node :species => 'human'
        node :name => 'Billy'
      end
    end
    => '{"pet":{"species":"turtle","name":"Anthony"}}'

Conveniently define which attributes to include. Create a new node with a different name for attributes you wish to alias.

    alice = Person.create!(:name => 'Alice', :profession => 'surgeon', :created_at => 28.years.ago, :gender => 'female')

    node :person => alice do
      attributes :name, :gender
      node :job => alice.profession
    end
    => '{"person":{"name":"Alice","gender":"female","job":"surgeon"}}'

Iterate through collections:

    wulong = Tea.new(:type => 'wulong')
    lucha = Tea.new(:type => 'green')

    collection :teas => [wulong, lucha] do
      attributes :type
    end
    => '{"teas":[{"type":"wulong"},{"type":"wulong"}]}'


You can also explicitly reference each item in the collection if you need to:

    collection :teas => teas do |tea|
      node :tea => tea do
        attributes :type
      end
      node :provider => lookup_provider_for(tea)
    end
    => '{"teas":[{"tea":{"type":"wulong"},{"provider":"Imperial Teas"}},{"tea":{"type":"wulong"},{"provider":"House of Tea"}}]}'

Partials have been implemented. This defaults to looking for a file in the same file as the template, or in a subdirectory called `partials`.

This can be overridden by re-implementing the `Petroglyph.partial(name)` method.

    collection :teas => teas do |tea|
      # partial(template_name, local_variables)
      partial :tea, :tea => tea
    end

## Rails 3

In your controller:

    render 'index', :locals => {:teas => teas}, :layout => false

Support for partials is non-standard at this time: create a subdirectory in the directory that your template lives in and call it `partials`.


## Caveat

There is currently no support for instance variables in Sinatra and Rails 3.

Avoid using `post` as a local variable name in sinatra. Since the template context in sinatra is the controller, calling `post` from your template will call the http `post` action. Same goes for `get`, `head`, `put`, etc, but these are less likely to be resources in your application.

## Related Projects

Other json templating libraries exist, some of which also generate XML.

* [Rabl](https://github.com/nesquena/rabl)
* [Tequila](https://github.com/inem/tequila)
* [Argonaut](https://github.com/jbr/argonaut)
* [JSON Builder](https://github.com/dewski/json_builder)
* [JBuilder](https://github.com/rails/jbuilder)
* [Jsonify](https://github.com/bsiggelkow/jsonify)
* [Representative](https://github.com/mdub/representative)
* [Tokamak](https://github.com/abril/tokamak)
