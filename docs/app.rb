# frozen_string_literal: true

require "bundler/setup"
require "sinatra"
require "slim"
require "action_view"
require "active_model"
require "ostruct"
require "rouge"
require "nokogiri"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dsfr-form_builder"

class DemoModel
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :url, :string
  attribute :phone, :string
  attribute :age, :integer
  attribute :bio, :string
  attribute :document
  attribute :terms, :boolean
  attribute :notifications, :boolean
  attribute :role, :string
  attribute :pronoun, :string
  attribute :interests

  def self.human_attribute_name(attribute, options = {})
    {
      name: "Nom complet",
      email: "Adresse email",
      url: "Site web",
      phone: "Numéro de téléphone",
      age: "Âge",
      bio: "Biographie",
      document: "Document",
      terms: "J'accepte les conditions",
      notifications: "Recevoir les notifications",
      role: "Rôle",
      pronoun: "Pronom",
      interests: "Centres d'intérêt"
    }.fetch(attribute.to_sym, attribute.to_s.humanize)
  end

  def self.interest_collection
    [
      OpenStruct.new(id: "sport", name: "Sport"),
      OpenStruct.new(id: "music", name: "Musique"),
      OpenStruct.new(id: "travel", name: "Voyage"),
      OpenStruct.new(id: "reading", name: "Lecture")
    ]
  end
end

class DocsApp < Sinatra::Base
  set :environment, :test
  set :views, File.expand_path("views", __dir__)

  helpers ActionView::Helpers::FormHelper
  helpers ActionView::Helpers::FormOptionsHelper
  helpers ActionView::Helpers::FormTagHelper
  helpers ActionView::Helpers::TagHelper
  helpers ActionView::Helpers::OutputSafetyHelper
  helpers ActionView::Helpers::CaptureHelper
  helpers ActionView::Helpers::TextHelper
  helpers ActionView::Context

  helpers do
    def protect_against_forgery? = false
    def form_authenticity_token = ""
    def interest_collection = DemoModel.interest_collection

    def code_block(code, language: "erb")
      formatter = Rouge::Formatters::HTML.new
      lexer = Rouge::Lexer.find(language)
      formatted_code = formatter.format(lexer.lex(code))
      "<pre class=\"highlight\"><code>#{formatted_code}</code></pre>"
    end


    def html_accordion(html_output, id: nil)
      accordion_id = "accordion-html-#{id}"
      doc = Nokogiri::HTML.fragment(html_output.to_str)
      formatted_html = doc.to_xhtml(indent: 2)
      <<~HTML
        <section class="fr-accordion fr-mt-2w">
          <h3 class="fr-accordion__title">
            <button type="button" class="fr-accordion__btn" aria-expanded="false" aria-controls="#{accordion_id}">HTML généré</button>
          </h3>
          <div class="fr-collapse" id="#{accordion_id}">
            #{code_block(formatted_html, language: "html")}
          </div>
        </section>
      HTML
    end


    def example(rb_code, namespace, model: nil)
      # ce _form_builder est utilisé dans le eval juste en dessous
      model_to_use = model || @demo_model
      _form_builder = Dsfr::FormBuilder.new(namespace, model_to_use, self, {})
      html_output = eval(rb_code.gsub(/\bf\./, "_form_builder."), binding)
      erb_code_to_display = rb_code.split("\n").reject(&:empty?).map { "<%= #{_1} %>" }.join("\n")

      <<~HTML
        <div class="fr-grid-row">
          <div class="fr-col-12 fr-col-md-8">#{html_output}</div>
        </div>
        #{code_block(erb_code_to_display)}
        #{html_accordion(html_output, id: namespace)}
      HTML
    end
  end

  HELPERS = %w[
    text_field text_area email_field url_field phone_field number_field
    file_field check_box collection_check_boxes radio_buttons select
    button submit label_with_hint
  ].freeze

  helpers do
    def helpers_list
      HELPERS
    end
  end

  get "/" do
    @demo_model = DemoModel.new
    @demo_model.errors.add(:name, "Ce champ est obligatoire")
    @demo_model.errors.add(:name, "Le nom doit contenir au moins 2 caractères")
    slim :index
  end

  get "/tous-les-helpers" do
    slim :tous_les_helpers
  end

  HELPERS.each do |helper|
    get "/#{helper.tr('_', '-')}" do
      @demo_model = DemoModel.new
      @helper_name = helper
      slim :"helpers/#{helper}"
    end
  end
end
