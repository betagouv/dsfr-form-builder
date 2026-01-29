require 'spec_helper'
require 'rack/test'
require_relative '../docs/app'

RSpec.describe DocsApp do
  include Rack::Test::Methods

  def app
    DocsApp
  end

  before do
    header "Host", "example.org"
  end

  describe "GET /" do
    it "returns 200" do
      get "/"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
    end
  end

  describe "GET /tous-les-helpers" do
    it "returns 200" do
      get "/tous-les-helpers"
      expect(last_response).to be_ok
      expect(last_response.status).to eq(200)
    end
  end

  DocsApp::HELPERS.each do |helper|
    describe "GET /#{helper.tr('_', '-')}" do
      it "returns 200" do
        get "/#{helper.tr('_', '-')}"
        expect(last_response).to be_ok
        expect(last_response.status).to eq(200)
      end
    end
  end

  describe "GET /non-existent-page" do
    it "returns 404" do
      get "/non-existent-page"
      expect(last_response.status).to eq(404)
    end
  end
end
