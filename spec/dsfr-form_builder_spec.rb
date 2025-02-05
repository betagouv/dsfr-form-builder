require_relative '../lib/dsfr-form_builder'
require 'spec_helper'
require 'action_view'
require 'active_support'
require 'active_model'
require 'nokogiri'

class TestHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
end

class Record
  include ActiveModel::Model
  attr_accessor :name
end

RSpec.describe Dsfr::FormBuilder, type: :helper do
  let(:helper) { TestHelper.new }
  let(:object) { Record.new(name: 'Jean Paul') }
  let(:builder) { Dsfr::FormBuilder.new(:record, object, helper, {}) }

  describe '#dsfr_text_field' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_text_field(:name)).to match_html(<<~HTML)
        <div class="fr-input-group">
          <label class="fr-label " for="record_name">Name</label>
          <input class="fr-input" type="text" value="Jean Paul" name="record[name]" id="record_name" />
        </div>
      HTML
    end
  end
end
