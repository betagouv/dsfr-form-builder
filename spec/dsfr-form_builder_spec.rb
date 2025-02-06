require 'spec_helper'

class TestHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
end

class Record
  include ActiveModel::Model
  attr_accessor :name, :pronom
end

RSpec.describe Dsfr::FormBuilder do
  let(:helper) { TestHelper.new }
  let(:object) { Record.new(name: 'Jean Paul', pronom: "il") }
  let(:builder) { Dsfr::FormBuilder.new(:record, object, helper, {}) }

  describe '#dsfr_text_field' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_text_field(:name)).to match_html(<<~HTML)
        <div class="fr-input-group">
          <label class="fr-label" for="record_name">Name</label>
          <input class="fr-input" type="text" value="Jean Paul" name="record[name]" id="record_name" />
        </div>
      HTML
    end
  end

  describe '#dsfr_text_area' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_text_area(:name)).to match_html(<<~HTML)
        <div class="fr-input-group">
          <label class="fr-label" for="record_name">Name</label>
          <textarea class="fr-input" name="record[name]" id="record_name">Jean Paul</textarea>
        </div>
      HTML
    end
  end

  describe "#dsfr_radio_buttons" do
    it 'generates the correct HTML' do
      choices = [
        { value: "elle", label: "Elle", hint: "« Elle était présente »" },
        { value: "il", label: "Il", hint: "« Il était présent »", checked: true },
        { value: "iel", label: "Iel", hint: "« Iel était présent·e »" }
      ]
      hint = "Choisissez le pronom qui vous correspond le mieux"
      expect(builder.dsfr_radio_buttons(:pronom, choices, legend: "Pronom", hint: hint)).to match_html(<<~HTML)
        <fieldset class="fr-fieldset">
          <legend class="fr-fieldset__legend--regular fr-fieldset__legend">
            Pronom
            <span class="fr-hint-text">
              Choisissez le pronom qui vous correspond le mieux
            </span>
          </legend>
          <div class="fr-fieldset__element">
            <div class="fr-radio-group">
              <input type="radio" value="elle" name="record[pronom]" id="record_pronom_elle">
              <label for="record_pronom_elle">
                Elle
                <span class="fr-hint-text">
                  « Elle était présente »
                </span>
              </label>
            </div>
          </div>
          <div class="fr-fieldset__element">
            <div class="fr-radio-group">
              <input type="radio" value="il" checked="checked" name="record[pronom]" id="record_pronom_il">
              <label for="record_pronom_il">
                Il
                <span class="fr-hint-text">
                  « Il était présent »
                </span>
              </label>
            </div>
          </div>
          <div class="fr-fieldset__element">
            <div class="fr-radio-group">
              <input type="radio" value="iel" name="record[pronom]" id="record_pronom_iel">
              <label for="record_pronom_iel">
                Iel
                <span class="fr-hint-text">
                  « Iel était présent·e »
                </span>
              </label>
            </div>
          </div>
        </fieldset>
      HTML
    end
  end
end
