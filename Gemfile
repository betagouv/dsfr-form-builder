# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rubocop"
gem "rubocop-rails-omakase", require: false, group: [ :development ]
gem "rspec"
gem "simplecov"
gem "actionview"
gem "activemodel"
gem "nokogiri"
gem "uri" # necessary on github actions
gem "diffy"

group :docs do
  gem "sinatra"
  gem "slim"
  gem "parklife"
  gem "rackup"
  gem "puma"
  gem "rouge"
  gem "rack-livereload"
  gem "guard-livereload", require: false
  gem "guard-rack"
end

gem "rake", "~> 13.3"
