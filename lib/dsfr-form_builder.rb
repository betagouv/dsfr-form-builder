module Dsfr
  include ActiveSupport::Configurable

  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::OutputSafetyHelper

    attr_accessor :display_required_tags

    def initialize(object_name, object, template, options)
      super
      self.display_required_tags = options.fetch(:display_required_tags, true)
    end

    def dsfr_button(value, options = {})
      options[:type] ||= :button
      options[:class] = join_classes("fr-btn", options[:class])
      button(value, options)
    end

    def dsfr_submit(value, options = {})
      dsfr_button(value, options.merge(type: :submit))
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

    def dsfr_input_group(attribute, opts, kind: :input, &block)
      classes = join_classes(
        "fr-#{kind}-group",
        ("fr-#{kind}-group--error" if @object&.errors&.include?(attribute)),
        opts[:class]
      )
      @template.content_tag(:div, class: classes, data: opts[:data]) do
        yield(block)
      end
    end

    def dsfr_input_field(attribute, input_kind, opts = {})
      dsfr_input_group(attribute, opts) do
        @template.safe_join(
          [
            dsfr_label_with_hint(attribute, opts),
            public_send(input_kind, attribute, class: "fr-input", **opts.except(:class, :hint, :label, :data)),
            dsfr_error_message(attribute)
          ]
        )
      end
    end

    def dsfr_file_field(attribute, opts = {})
      dsfr_input_group(attribute, opts, kind: :upload) do
        @template.safe_join(
          [
            dsfr_label_with_hint(attribute, opts.except(:class)),
            file_field(attribute, class: "fr-upload", **opts.except(:class, :hint, :label, :data)),
            dsfr_error_message(attribute)
          ].compact
        )
      end
    end

    def dsfr_check_box(attribute, opts = {}, checked_value = "1", unchecked_value = "0")
      @template.content_tag(:div, class: "fr-fieldset__element #{'fr-fieldset__element--inline' if opts.delete(:inline)}") do
        dsfr_input_group(attribute, opts, kind: :checkbox) do
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
      html_options[:class] = [ "fr-fieldset", html_options[:class] ].compact.join(" ")
      @template.content_tag(:fieldset, **html_options) do
        @template.safe_join([
          @template.content_tag(:legend, legend, class: "fr-fieldset__legend--regular fr-fieldset__legend"),
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

    def dsfr_select(attribute, choices, input_options: {}, **opts)
      dsfr_input_group(attribute, opts, kind: :select) do
        @template.safe_join(
          [
            dsfr_label_with_hint(attribute, opts),
            dsfr_select_tag(attribute, choices, opts.merge(input_options).except(:hint, :name)),
            dsfr_error_message(attribute)
          ]
        )
      end
    end

    def dsfr_select_tag(attribute, choices, opts)
      opts[:class] = join_classes("fr-select", opts[:class])
      options = opts.slice(:include_blank, :selected, :disabled)
      html_options = opts.except(:include_blank, :selected, :disabled)
      select(attribute, choices, options, **html_options)
    end

    def dsfr_radio_buttons(attribute, choices, legend: nil, hint: nil, **opts)
      legend_content = @template.safe_join([
        legend || @object.class.human_attribute_name(attribute),
        hint_tag(hint)
      ])
      @template.content_tag(:fieldset, class: "fr-fieldset") do
        @template.safe_join(
          [
            @template.content_tag(:legend, legend_content, class: "fr-fieldset__legend--regular fr-fieldset__legend"),
            choices.map { |c| dsfr_radio_option(attribute, value: c[:value], label_text: c[:label], hint: c[:hint], checked: c[:checked], **opts) }
          ]
        )
      end
    end

    def dsfr_radio_option(attribute, value:, label_text:, hint:, checked:, rich: false, **opts)
      @template.content_tag(:div, class: "fr-fieldset__element") do
        classes = rich ? "fr-radio-group fr-radio-rich" : "fr-radio-group"
        @template.content_tag(:div, class: classes) do
          @template.safe_join(
            [
              radio_button(attribute, value, checked:, **opts),
              dsfr_label_with_hint(attribute, opts.merge(label_text: label_text, hint: hint, value: value))
            ]
          )
        end
      end
    end

    def dsfr_label_with_hint(attribute, opts = {})
      label_class = "fr-label #{opts[:class]}"
      label(attribute, class: label_class, value: opts[:value]) do
        label_and_tags = [ opts[:label_text] || label_value(attribute, opts) ]
        label_and_tags.push(required_tag) if opts[:required] && display_required_tags
        label_and_tags.push(hint_tag(opts[:hint])) if opts[:hint]

        @template.safe_join(label_and_tags)
      end
    end

    def required_tag
      @template.content_tag(:span, "*", class: "fr-text-error")
    end

    def dsfr_error_message(attr)
      return if @object.nil? || @object.errors[attr].none?

      @template.content_tag(:p, class: "fr-messages-group") do
        safe_join(@object.errors.full_messages_for(attr).map do |msg|
          @template.content_tag(:span, msg, class: "fr-message fr-message--error")
        end)
      end
    end

    def hint_tag(text)
      @template.content_tag(:span, text, class: "fr-hint-text") if text
    end

    def join_classes(*arr)
      Array.wrap(arr).compact.join(" ")
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
