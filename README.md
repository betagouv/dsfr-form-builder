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

## Mettre à jour la gemme

Pour déployer une nouvelle version, il faut avoir le rôle de mainteneur sur RubyGems (et activer le MFA), puis :

1. Incrémenter le numéro de version et créer un tag
2. Builder la gemme et l'envoyer sur RubyGems et Github

```
gem bump --sign --tag --push
gem release --push --github --repo betagouv/dsfr-form-builder
```

### Configurer le poste (la première fois seulement)
```
# Installer le plugin Bundler
gem install gem-release
# Si vous n'êtes pas connecté, customiser les permissions pour que la clé puisse déployer de nouvelles releases
gem login

# Pour signer les tags
git config --global tag.gpgsign true
key=$(git config --global user.signingkey 2>/dev/null || gpg --list-secret-keys --keyid-format=long --with-colons 2>/dev/null | awk -F: '/^sec:/ { print $5; exit }')
if [[ -z "$key" ]]; then
  echo "Aucune clé trouvée. Lancer : gpg --full-generate-key"
  echo "Puis relancer ce script."
  exit 1
fi
git config --global user.signingkey "$key"
echo "Git est maintenant configuré avec la clé GPG : $key"
echo "Ajouter cette clé publique dans GitHub/GitLab:"
gpg --armor --export "$key"
```

## Licence

Le code source et la gem sont distribués sous licence [MIT](https://github.com/betagouv/dsfr-form-builder/blob/main/LICENSE).
