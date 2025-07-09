$LOAD_PATH.push File.expand_path('lib', __dir__)

require_relative 'lib/dsfr-form_builder/version'

Gem::Specification.new do |spec|
  spec.name        = 'dsfr-form_builder'
  spec.version     = Dsfr::FormBuilder::VERSION
  spec.authors     = [ 'BetaGouv developers' ]
  spec.email       = [ 'antoine.girard@beta.gouv.fr' ]
  spec.homepage    = 'https://github.com/betagouv/dsfr-form-builder'
  spec.summary     = "Ruby on Rails form builder pour le Système de Design de l'État (DSFR)"
  spec.description = "Cette librairie de composants vise à simplifier la création de formulaire au DSFR (Système de Design de l'État) dans les applications web utilisant Ruby On Rails"
  spec.license     = 'MIT'
  spec.metadata = {
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => spec.homepage,
    'bug_tracker_uri'   => spec.homepage + '/issues',
    'changelog_uri'     => spec.homepage + '/releases',
    'documentation_uri' => 'https://www.rubydoc.info/gems/dsfr-form-builder/'
  }

  spec.files = Dir['lib/**/*']

  spec.required_ruby_version = '>= 3.2'

  %w[actionview activemodel activesupport].each do |lib|
    spec.add_dependency(lib, '>= 6.1', '< 9.0')
  end
end
