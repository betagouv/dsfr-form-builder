# frozen_string_literal: true

require_relative "app"
require "rack-livereload"

use Rack::LiveReload
run DocsApp
