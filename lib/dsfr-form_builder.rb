module Dsfr
  include ActiveSupport::Configurable

  class FormBuilder < ActionView::Helpers::FormBuilder
    VERSION = "0.0.12"

    include ActionView::Helpers::OutputSafetyHelper

    attr_accessor :display_required_tags

    def initialize(object_name, object, template, options)
      super
      self.display_required_tags = options.fetch(:display_required_tags, true)
    end

    def dsfr_button(value = nil, options = {}, &block)
      if block_given?
        options = value || {}
        value = @template.capture { yield(value) }
      end
      options[:type] ||= :button
      options[:class] = @template.class_names("fr-btn", options[:class])
      button(value, options)
    end

    def dsfr_submit(value = nil, options = {}, &block)
      if block_given?
        options = value || {}
        value = @template.capture { yield(value) }
      end
      options[:type] = :submit
      dsfr_button(value, options)
    end

    %i[text_field text_area email_field url_field phone_field number_field].each do |field_type|
      define_method("dsfr_#{field_type}") do |attribute, **options|
        dsfr_input_field(attribute, field_type, **options)
      end
    end

    def dsfr_input_group(attribute, kind: :input, **opts)
      @template.tag.div(
        data: opts[:data],
        class: @template.class_names(
              "fr-#{kind}-group",
              opts[:class],
              "fr-#{kind}-group--error" => @object&.errors&.include?(attribute)
        )
      ) { yield }
    end

    def dsfr_input_field(attribute, input_kind, opts = {})
      dsfr_input_group(attribute, **opts) do
        @template.safe_join([
          dsfr_label_with_hint(attribute, opts.except(:value)),
          public_send(input_kind, attribute, class: "fr-input", **opts.except(:class, :hint, :label, :data)),
          dsfr_error_message(attribute)
        ])
      end
    end

    def dsfr_file_field(attribute, opts = {})
      dsfr_input_group(attribute, **opts, kind: :upload) do
        @template.safe_join([
          dsfr_label_with_hint(attribute, opts.except(:class, :value)),
          file_field(attribute, class: "fr-upload", **opts.except(:class, :hint, :label, :data)),
          dsfr_error_message(attribute)
        ])
      end
    end

    def dsfr_check_box(attribute, opts = {}, checked_value = "1", unchecked_value = "0")
      @template.tag.div(class: @template.class_names("fr-fieldset__element", "fr-fieldset__element--inline" => opts.delete(:inline))) do
        dsfr_input_group(attribute, **opts, kind: :checkbox) do
          @template.safe_join([
            check_box(attribute, opts.except(:label, :hint), checked_value, unchecked_value),
            dsfr_label_with_hint(attribute, opts)
          ])
        end
      end
    end

    def dsfr_collection_check_boxes(method, collection, value_method, text_method, opts = {}, html_options = {})
      legend = opts.delete(:legend) || @object&.class&.human_attribute_name(method)
      if legend.blank?
        raise ArgumentError.new("Please provide the legend option, or use an object whose class responds to :human_attribute_name")
      end
      legend = @template.safe_join([ legend, hint_tag(opts.delete(:hint)) ])
      name = opts.delete(:name) || "#{@object_name}[#{method}][]"
      html_options[:class] = @template.class_names("fr-fieldset", html_options[:class])
      @template.tag.fieldset(**html_options) do
        @template.safe_join([
          @template.tag.legend(legend, class: "fr-fieldset__legend--regular fr-fieldset__legend"),
          @template.hidden_field_tag(name, "", id: nil),
          collection.map do |item|
            value = item.send(value_method)
            checkbox_options = {
              name: name,
              value: value,
              id: field_id(method, value),
              label: item.send(text_method),
              inline: opts[:inline],
              checked: selected?(method, value),
              include_hidden: false
            }
            dsfr_check_box(method, checkbox_options, value, "")
          end
        ])
      end
    end

    def dsfr_select(attribute, choices, input_options = {}, **html_options)
      select_html_options = html_options.dup.except(:hint, :name)
      select_html_options[:class] = @template.class_names("fr-select", select_html_options[:class])
      dsfr_input_group(attribute, **html_options, kind: :select) do
        @template.safe_join([
          dsfr_label_with_hint(attribute, html_options),
          select(attribute, choices, input_options, **select_html_options),
          dsfr_error_message(attribute)
        ])
      end
    end

    def dsfr_radio_buttons(attribute, choices, legend: nil, hint: nil, **opts)
      legend_content = @template.safe_join([
        legend || @object.class.human_attribute_name(attribute),
        hint_tag(hint)
      ])
      @template.tag.fieldset(class: "fr-fieldset") do
        @template.safe_join([
          @template.tag.legend(legend_content, class: "fr-fieldset__legend--regular fr-fieldset__legend"),
          choices.map do |choice|
            dsfr_radio_option(
              attribute,
              value: choice[:value],
              label_text: choice[:label],
              hint: choice[:hint],
              checked: choice[:checked],
              **opts
            )
          end
        ])
      end
    end

    def dsfr_radio_option(attribute, value:, label_text:, hint:, checked:, rich: false, **opts)
      @template.tag.div(class: "fr-fieldset__element") do
        @template.tag.div(class: @template.class_names("fr-radio-group", "fr-radio-rich" => rich)) do
          @template.safe_join([
            radio_button(attribute, value, checked:, **opts),
            dsfr_label_with_hint(attribute, opts.merge(label_text: label_text, hint: hint, value: value))
          ])
        end
      end
    end

    def dsfr_label_with_hint(attribute, opts = {})
      label(attribute, class: @template.class_names("fr-label", opts[:class]), value: opts[:value]) do
        @template.safe_join([
          opts[:label_text] || label_value(attribute, opts),
          (required_tag if opts[:required] && display_required_tags),
          (hint_tag(opts[:hint]) if opts[:hint])
        ])
      end
    end

    def required_tag
      @template.tag.span("*", class: "fr-text-error")
    end

    def dsfr_error_message(attr)
      return if @object.nil? || @object.errors[attr].none?

      @template.tag.p(class: "fr-messages-group") do
        safe_join(@object.errors.full_messages_for(attr).map do |msg|
          @template.tag.span(msg, class: "fr-message fr-message--error")
        end)
      end
    end

    def hint_tag(text)
      @template.tag.span(text, class: "fr-hint-text") if text
    end

    def label_value(attribute, opts)
      return opts[:label] if opts[:label]

      (@object.try(:object) || @object).class.human_attribute_name(attribute)
    end

    private

    # TODO: Allow this helper to be used by select options and radio buttons.
    def selected?(method, value)
      return unless @object.respond_to?(method)

      (@object.send(method) || []).include?(value)
    end
  end
end
