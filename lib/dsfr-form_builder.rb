module Dsfr
  include ActiveSupport::Configurable


  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::OutputSafetyHelper

    attr_accessor :display_required_tags

    def initialize(object_name, object, template, options)
      super
      self.display_required_tags = options.fetch(:display_required_tags, true)
    end

    def dsfr_text_field(attribute, opts = {})
      dsfr_input_field(attribute, :text_field, opts)
    end

    def dsfr_text_area(attribute, opts = {})
      dsfr_input_field(attribute, :text_area, opts)
    end

    def dsfr_email_field(attribute, opts = {})
      dsfr_input_field(attribute, :email_field, opts)
    end

    def dsfr_url_field(attribute, opts = {})
      dsfr_input_field(attribute, :url_field, opts)
    end

    def dsfr_phone_field(attribute, opts = {})
      dsfr_input_field(attribute, :phone_field, opts)
    end

    def dsfr_number_field(attribute, opts = {})
      dsfr_input_field(attribute, :number_field, opts)
    end

    def dsfr_input_group(attribute, opts, &block)
      @template.content_tag(:div, class: input_group_classes(attribute, opts), data: opts[:data]) do
        yield(block)
      end
    end

    def dsfr_input_field(attribute, input_kind, opts = {})
      dsfr_input_group(attribute, opts) do
        @template.safe_join(
          [
            dsfr_label_with_hint(attribute, opts),
            public_send(input_kind, attribute, class: "fr-input", **opts.except(:class, :hint)),
            dsfr_error_message(attribute)
          ]
        )
      end
    end

    def dsfr_check_box(attribute, opts = {}, checked_value = "1", unchecked_value = "0")
      @template.content_tag(:div, class: "fr-checkbox-group") do
        @template.safe_join(
          [
            check_box(attribute, opts, checked_value, unchecked_value),
            dsfr_label_with_hint(attribute, opts)
          ]
        )
      end
    end

    def dsfr_select(attribute, choices, input_options: {}, **opts)
      @template.content_tag(:div, class: "fr-select-group") do
        @template.safe_join(
          [
            dsfr_label_with_hint(attribute, opts),
            dsfr_select_tag(attribute, choices, **opts, **(input_options)),
            dsfr_error_message(attribute)
          ]
        )
      end
    end

    def dsfr_select_tag(attribute, choices, opts)
      select(attribute, choices, { include_blank: opts[:include_blank] }, class: "fr-select")
    end

    def dsfr_radio_buttons(attribute, choices, legend: nil, hint: nil, **opts)
      legend_content = @template.safe_join([
        legend || @object.class.human_attribute_name(attribute),
        hint ? hint_tag(hint) : nil
      ].compact)
      @template.content_tag(:fieldset, class: "fr-fieldset") do
        @template.safe_join(
          [
            @template.content_tag(:legend, legend_content, class: "fr-fieldset__legend--regular fr-fieldset__legend"),
            choices.map { |c| dsfr_radio_option(attribute, value: c[:value], label_text: c[:label], hint: c[:hint], **opts) }
          ]
        )
      end
    end

    def dsfr_radio_option(attribute, value:, label_text:, hint:, rich: false, **opts)
      @template.content_tag(:div, class: "fr-fieldset__element") do
        classes = rich ? "fr-radio-group fr-radio-rich" : "fr-radio-group"
        @template.content_tag(:div, class: classes) do
          @template.safe_join(
            [
              radio_button(attribute, value, **opts),
              label([ attribute, value ].join("_").to_sym) do
                @template.safe_join(
                  [
                    label_text,
                    hint.present? ? @template.content_tag(:span, hint, class: "fr-hint-text") : nil
                  ]
                )
              end
            ]
          )
        end
      end
    end

    def dsfr_label_with_hint(attribute, opts = {})
      label_class = "fr-label #{opts[:class]}"
      label(attribute, class: label_class) do
        label_and_tags = [ label_value(attribute, opts) ]
        label_and_tags.push(required_tag) if opts[:required] && display_required_tags
        label_and_tags.push(hint_tag(opts[:hint])) if opts[:hint]

        @template.safe_join(label_and_tags)
      end
    end

    def required_tag
      @template.content_tag(:span, "*", class: "fr-text-error")
    end

    def dsfr_error_message(attr)
      return if @object.errors[attr].none?

      @template.content_tag(:p, class: "fr-messages-group") do
        safe_join(@object.errors.full_messages_for(attr).map do |msg|
          @template.content_tag(:span, msg, class: "fr-message fr-message--error")
        end)
      end
    end

    def hint_tag(text)
      return "" unless text

      @template.content_tag(:span, class: "fr-hint-text") do
        text
      end

      @template.content_tag(:span, text, class: "fr-hint-text")
    end

    def join_classes(arr)
      arr.compact.join(" ")
    end

    def input_group_classes(attribute, opts)
      join_classes(
        [
          "fr-input-group",
          @object.errors[attribute].any? ? "fr-input-group--error" : nil,
          opts[:class]
        ]
      )
    end

    def label_value(attribute, opts)
      return opts[:label] if opts[:label]

      (@object.try(:object) || @object).class.human_attribute_name(attribute)
    end
  end
end
