require 'spec_helper'

class TestHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
end

class Record
  include ActiveModel::Model
  attr_accessor :name, :pronom, :role
end

RSpec.describe Dsfr::FormBuilder do
  let(:helper) { TestHelper.new }
  let(:object) { Record.new(name: 'Jean Paul', pronom: "il", role: "editor") }
  let(:builder) { Dsfr::FormBuilder.new(:record, object, helper, {}) }

  describe '#dsfr_button' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_button("Button")).to match_html(<<~HTML.strip)
        <button name="button" type="button" class="fr-btn">Button</button>
      HTML
    end

    context 'when passing options' do
      it 'generates the correct HTML' do
        expect(builder.dsfr_button("Button", name: nil, class: "extra-class", data: { controller: :rails }, aria: { busy: true })).to match_html(<<~HTML.strip)
          <button type="button" class="fr-btn extra-class" data-controller="rails" aria-busy="true">Button</button>
        HTML
      end
    end

    context 'when called with a block' do
      it 'generates the correct HTML' do
        result = builder.dsfr_button { "Block Content" }
        expect(result).to match_html(<<~HTML.strip)
          <button name="button" type="button" class="fr-btn">Block Content</button>
        HTML
      end

      it 'accepts options when called with a block' do
        result = builder.dsfr_button(class: "extra-class", data: { controller: :rails }) { "Block Content" }
        expect(result).to match_html(<<~HTML.strip)
          <button name="button" type="button" class="fr-btn extra-class" data-controller="rails">Block Content</button>
        HTML
      end
    end
  end

  describe '#dsfr_submit' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_submit("Submit")).to match_html(<<~HTML.strip)
        <button name="button" type="submit" class="fr-btn">Submit</button>
      HTML
    end

    context 'when passing options' do
      it 'generates the correct HTML' do
        expect(builder.dsfr_submit("Submit", name: nil, class: "extra-class", data: { controller: :rails }, aria: { busy: true })).to match_html(<<~HTML.strip)
          <button type="submit" class="fr-btn extra-class" data-controller="rails" aria-busy="true">Submit</button>
        HTML
      end
    end

    context 'when called with a block' do
      it 'generates the correct HTML' do
        result = builder.dsfr_submit { "Block Submit" }
        expect(result).to match_html(<<~HTML.strip)
          <button name="button" type="submit" class="fr-btn">Block Submit</button>
        HTML
      end

      it 'accepts options when called with a block' do
        result = builder.dsfr_submit(class: "extra-class", data: { controller: :rails }) { "Block Submit" }
        expect(result).to match_html(<<~HTML.strip)
          <button name="button" type="submit" class="fr-btn extra-class" data-controller="rails">Block Submit</button>
        HTML
      end
    end
  end

  describe '#dsfr_input_group' do
    it 'wraps block content inside the div when rendered through ERB' do
      view = ActionView::Base.with_empty_template_cache.new(
        ActionView::LookupContext.new([]), {}, nil
      )

      result = view.render(inline: <<~ERB, locals: { object: object })
        <% f = Dsfr::FormBuilder.new(:record, object, self, {}) %>
        <%= f.dsfr_input_group(:name) do %>
          <%= f.dsfr_label_with_hint(:name, {}) %>
          <%= f.text_field(:name, class: "fr-input") %>
        <% end %>
      ERB

      wrapper = Nokogiri::HTML.fragment(result).at_css('div.fr-input-group')
      expect(wrapper).to be_present, "expected a div.fr-input-group wrapper"
      expect(wrapper.css('label').count).to eq(1)
      expect(wrapper.css('input').count).to eq(1)
    end
  end

  describe '#dsfr_text_field' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_text_field(:name)).to match_html(<<~HTML)
        <div class="fr-input-group">
          <label class="fr-label" for="record_name">Name</label>
          <input class="fr-input" type="text" value="Jean Paul" name="record[name]" id="record_name" />
        </div>
      HTML
    end

    context 'when object is nil' do
      let(:object) { nil }

      it "doesn't raise" do
        expect { builder.dsfr_text_field(:name, label: "Label") }.not_to raise_error
      end
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

    context 'when object is nil' do
      let(:object) { nil }

      it "doesn't raise" do
        expect { builder.dsfr_text_area(:name, label: "Label") }.not_to raise_error
      end
    end
  end

  describe '#dsfr_file_field' do
    it 'generates the correct HTML' do
      expect(builder.dsfr_file_field(:name)).to match_html(<<~HTML)
        <div class="fr-upload-group">
          <label class="fr-label" for="record_name">Name</label>
          <input class="fr-upload" type="file" name="record[name]" id="record_name" />
        </div>
      HTML
    end

    it "supports hint and required options" do
      expect(builder.dsfr_file_field(:name, hint: "Upload a file", required: true)).to match_html(<<~HTML)
        <div class="fr-upload-group">
          <label class="fr-label" for="record_name">
            Name
            <span class="fr-text-error">*</span>
            <span class="fr-hint-text">Upload a file</span>
          </label>
          <input class="fr-upload" required="required" type="file" name="record[name]" id="record_name" />
        </div>
      HTML
    end

    context 'when object is nil' do
      let(:object) { nil }

      it "doesn't raise" do
        expect { builder.dsfr_file_field(:name, label: "Label") }.not_to raise_error
      end
    end
  end

  describe "#dsfr_select" do
    let(:object) { Record.new(name: 'Jean Paul', pronom: "il", role: nil) }
    let(:choices) { [ [ "Administrateur", "admin" ], [ "Éditeur", "editor" ], [ "Lecteur", "reader" ] ] }

    it "generates the correct HTML" do
      expect(builder.dsfr_select(:role, choices)).to match_html(<<~HTML)
        <div class="fr-select-group">
          <label class="fr-label" for="record_role">Role</label>
          <select class="fr-select" name="record[role]" id="record_role">
            <option value="admin">Administrateur</option>
            <option value="editor">Éditeur</option>
            <option value="reader">Lecteur</option>
          </select>
        </div>
      HTML
    end

    context "le record a déjà une valeur" do
      let(:object) { Record.new(name: 'Jean Paul', pronom: "il", role: "editor") }

      it "generates the correct HTML" do
        expect(builder.dsfr_select(:role, choices)).to match_html(<<~HTML)
          <div class="fr-select-group">
            <label class="fr-label" for="record_role">Role</label>
            <select class="fr-select" name="record[role]" id="record_role">
              <option value="admin">Administrateur</option>
              <option selected="true" value="editor">Éditeur</option>
              <option value="reader">Lecteur</option>
            </select>
          </div>
        HTML
      end
    end

    it "supports required option and include_blank options" do
      expect(builder.dsfr_select(:role, choices, { include_blank: "veuillez choisir une option" }, required: true)).to match_html(<<~HTML)
        <div class="fr-select-group">
          <label class="fr-label" for="record_role">
            Role
            <span class="fr-text-error">*</span>
          </label>
          <select required="required" class="fr-select" name="record[role]" id="record_role">
            <option value="">veuillez choisir une option</option>
            <option value="admin">Administrateur</option>
            <option value="editor">Éditeur</option>
            <option value="reader">Lecteur</option>
          </select>
        </div>
      HTML
    end

    it "supports hint" do
      expect(builder.dsfr_select(:role, choices, {}, hint: "Choisissez votre role")).to match_html(<<~HTML)
        <div class="fr-select-group">
          <label class="fr-label" for="record_role">
            Role
            <span class="fr-hint-text">Choisissez votre role</span>
          </label>
          <select class="fr-select" name="record[role]" id="record_role">
            <option value="admin">Administrateur</option>
            <option value="editor">Éditeur</option>
            <option value="reader">Lecteur</option>
          </select>
        </div>
      HTML
    end

    it "supports the disabled: true option" do
      expect(builder.dsfr_select(:role, choices, {}, disabled: true)).to match_html(<<~HTML)
        <div class="fr-select-group">
          <label class="fr-label" for="record_role">Role</label>
          <select disabled="true" class="fr-select" name="record[role]" id="record_role">
            <option value="admin">Administrateur</option>
            <option value="editor">Éditeur</option>
            <option value="reader">Lecteur</option>
          </select>
        </div>
      HTML
    end

    # selon https://api.rubyonrails.org/v8.0/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-select
    # je comprends que `disabled: value` devrait disabler une seule option
    # mais ce n'est pas le cas 🤷
    #
    # it "supports the disabled: some_value" do
    #   expect(builder.dsfr_select(:role, choices, {}, disabled: 'editor')).to match_html(<<~HTML)
    #     <div class="fr-select-group">
    #       <label class="fr-label" for="record_role">Role</label>
    #       <select class="fr-select" name="record[role]" id="record_role">
    #         <option value="admin">Administrateur</option>
    #         <option value="editor" disabled="disabled">Éditeur</option>
    #         <option value="reader">Lecteur</option>
    #       </select>
    #     </div>
    #   HTML
    # end
  end

  describe "#dsfr_check_box" do
    it 'generates the correct HTML' do
      expect(builder.dsfr_check_box(:name)).to match_html(<<~HTML)
        <div class="fr-fieldset__element">
          <div class="fr-checkbox-group">
            <input name="record[name]" type="hidden" value="0" autocomplete="off">
            <input type="checkbox" value="1" name="record[name]" id="record_name" />
            <label class="fr-label" for="record_name">Name</label>
          </div>
        </div>
      HTML
    end

    context "with custom settings" do
      it 'generates the correct HTML' do
        expect(builder.dsfr_check_box(:name, { label: "Nom", hint: "Votre nom", inline: true }, "checked", "unchecked")).to match_html(<<~HTML)
          <div class="fr-fieldset__element fr-fieldset__element--inline">
            <div class="fr-checkbox-group">
              <input name="record[name]" type="hidden" value="unchecked" autocomplete="off">
              <input type="checkbox" value="checked" name="record[name]" id="record_name" />
              <label class="fr-label" for="record_name">
                Nom
                <span class="fr-hint-text">
                  Votre nom
                </span>
              </label>
            </div>
          </div>
        HTML
      end
    end

    context 'when object is nil' do
      let(:object) { nil }

      it "doesn't raise" do
        expect { builder.dsfr_check_box(:name, label: "Label") }.not_to raise_error
      end
    end
  end

  describe "#dsfr_collection_check_boxes" do
    Item = Struct.new(:id, :name, keyword_init: true)

    let(:collection) { [ Item.new(id: 1, name: "Option 1"), Item.new(id: 2, name: "Option 2") ] }

    it "generates the correct HTML" do
      expect(builder.dsfr_collection_check_boxes(:tags, collection, :id, :name)).to match_html(<<~HTML)
        <fieldset class="fr-fieldset">
          <legend class="fr-fieldset__legend--regular fr-fieldset__legend">Tags</legend>
          <input type="hidden" name="record[tags][]" value="" autocomplete="off">
          <div class="fr-fieldset__element">
            <div class="fr-checkbox-group">
              <input name="record[tags][]" value="1" id="record_tags_1" type="checkbox" />
              <label class="fr-label" for="record_tags_1">Option 1</label>
            </div>
          </div>
          <div class="fr-fieldset__element">
            <div class="fr-checkbox-group">
              <input name="record[tags][]" value="2" id="record_tags_2" type="checkbox" />
              <label class="fr-label" for="record_tags_2">Option 2</label>
            </div>
          </div>
        </fieldset>
      HTML
    end

    context "with all options combined" do
      it "generates the correct HTML" do
        expect(builder.dsfr_collection_check_boxes(:tags, collection, :id, :name,
          { legend: "Choose tags", hint: "Select multiple options", name: "custom[field][]", inline: true },
          { class: "custom-class", data: { testid: "collection" } })).to match_html(<<~HTML)
          <fieldset class="fr-fieldset custom-class" data-testid="collection">
            <legend class="fr-fieldset__legend--regular fr-fieldset__legend">
              Choose tags
              <span class="fr-hint-text">
                Select multiple options
              </span>
            </legend>
            <input type="hidden" name="custom[field][]" value="" autocomplete="off">
            <div class="fr-fieldset__element fr-fieldset__element--inline">
              <div class="fr-checkbox-group">
                <input name="custom[field][]" value="1" id="record_tags_1" type="checkbox" />
                <label class="fr-label" for="record_tags_1">Option 1</label>
              </div>
            </div>
            <div class="fr-fieldset__element fr-fieldset__element--inline">
              <div class="fr-checkbox-group">
                <input name="custom[field][]" value="2" id="record_tags_2" type="checkbox" />
                <label class="fr-label" for="record_tags_2">Option 2</label>
              </div>
            </div>
          </fieldset>
        HTML
      end
    end

    context "when object is nil" do
      let(:object) { nil }

      it "doesn't raise" do
        expect { builder.dsfr_collection_check_boxes(:tags, collection, :id, :name, legend: "Choose tags") }.not_to raise_error
      end
    end
  end

  describe "#dsfr_radio_buttons" do
    let(:choices) do
      [
        { value: "elle", label: "Elle", hint: "« Elle était présente »", checked: true },
        { value: "il", label: "Il", hint: "« Il était présent »", checked: false },
        { value: "iel", label: "Iel", hint: "« Iel était présent·e »" }
      ]
    end
    let(:hint) { "Choisissez le pronom qui vous correspond le mieux" }

    it 'generates the correct HTML' do
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
              <input type="radio" value="elle", checked="checked", name="record[pronom]" id="record_pronom_elle">
              <label class="fr-label" for="record_pronom_elle">
                Elle
                <span class="fr-hint-text">
                  « Elle était présente »
                </span>
              </label>
            </div>
          </div>
          <div class="fr-fieldset__element">
            <div class="fr-radio-group">
              <input type="radio" value="il" name="record[pronom]" id="record_pronom_il">
              <label class="fr-label" for="record_pronom_il">
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
              <label class="fr-label" for="record_pronom_iel">
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

    context 'with rich option' do
      it 'generates the correct HTML' do
        expect(builder.dsfr_radio_buttons(:pronom, choices, legend: "Pronom", hint: hint, rich: true)).to match_html(<<~HTML)
          <fieldset class="fr-fieldset">
            <legend class="fr-fieldset__legend--regular fr-fieldset__legend">
              Pronom
              <span class="fr-hint-text">
                Choisissez le pronom qui vous correspond le mieux
              </span>
            </legend>
            <div class="fr-fieldset__element">
              <div class="fr-radio-group fr-radio-rich">
                <input type="radio" value="elle" checked="checked" name="record[pronom]" id="record_pronom_elle">
                <label class="fr-label" for="record_pronom_elle">
                  Elle
                  <span class="fr-hint-text">
                    « Elle était présente »
                  </span>
                </label>
              </div>
            </div>
            <div class="fr-fieldset__element">
              <div class="fr-radio-group fr-radio-rich">
                <input type="radio" value="il" name="record[pronom]" id="record_pronom_il">
                <label class="fr-label" for="record_pronom_il">
                  Il
                  <span class="fr-hint-text">
                    « Il était présent »
                  </span>
                </label>
              </div>
            </div>
            <div class="fr-fieldset__element">
              <div class="fr-radio-group fr-radio-rich">
                <input type="radio" value="iel" name="record[pronom]" id="record_pronom_iel">
                <label class="fr-label" for="record_pronom_iel">
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

    context 'when object is nil' do
      let(:object) { nil }

      it "doesn't raise" do
        expect { builder.dsfr_radio_buttons(:pronom, choices, legend: "Legend", label_text: "Label") }.not_to raise_error
      end
    end
  end
end
