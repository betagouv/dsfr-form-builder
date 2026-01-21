$LOAD_PATH.push File.expand_path('lib', __dir__)

METADATA = {
  'bug_tracker_uri' => 'https://github.com/betagouv/dsfr-form-builder/issues',
  'changelog_uri' => 'https://github.com/betagouv/dsfr-form-builder/releases',
  'documentation_uri' => 'https://www.rubydoc.info/gems/dsfr-form-builder/',
  'homepage_uri' => 'https://github.com/betagouv/dsfr-form-builder',
  'source_code_uri' => 'https://github.com/betagouv/dsfr-form-builder'
}.freeze


Gem::Specification.new do |spec|
  spec.name        = 'dsfr-form_builder'
  spec.version     = '0.0.9'
  spec.authors     = [ 'BetaGouv developers' ]
  spec.email       = [ 'antoine.girard@beta.gouv.fr' ]
  spec.homepage    = 'https://github.com/betagouv/dsfr-form-builder'
  spec.summary     = "Ruby on Rails form builder pour le Système de Design de l'État (DSFR)"
  spec.description = "Cette librairie de composants vise à simplifier la création de formulaire au DSFR (Système de Design de l'État) dans les applications web utilisant Ruby On Rails"
  spec.license     = 'MIT'
  spec.metadata    = METADATA

  spec.files = Dir['lib/**/*']

  spec.required_ruby_version = '>= 3.2'

  %w[actionview activemodel activesupport].each do |lib|
    spec.add_dependency(lib, '>= 6.1', '< 9.0')
  end
end
