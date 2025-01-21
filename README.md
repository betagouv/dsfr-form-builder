# Form builder du DSFR

[![Gem Version](https://badge.fury.io/rb/dsfr-form_builder.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/dsfr-form_builder)

Cette gem permet de créer des formulaires avec Ruby on Rails en utilisant le design system de l'Etat français (DSFR).

## Installation

Ajoutez cette ligne à votre Gemfile :

```ruby
gem 'dsfr-form_builder'
```

Spécifiez l’utilisation du builder dans votre formulaire :

```erb
<%= form_with model: @user, builder: Dsfr::FormBuilder do |f| %>
  <%= f.text_field :name %>
<% end %>
```

Vous pouvez également spécifier le builder par défaut dans votre fichier `application.rb` :

```ruby
config.action_view.default_form_builder = Dsfr::FormBuilder
```

## Licence

Le code source et la gem sont distribués sous licence [MIT](https://github.com/betagouv/dsfr-form-builder/blob/main/LICENSE).