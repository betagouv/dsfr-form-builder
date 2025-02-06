RSpec::Matchers.define :match_html do |expected|
  def normalize_html(html)
    # important to strip around the raw HTML input
    doc = Nokogiri::HTML.fragment(html.strip)
    # strip all attributes values
    doc.traverse do |node|
      if node.respond_to?(:attributes)
        node.attributes.each do |name, attr|
          attr.value = attr.value.strip
        end
      end
      if node.text?
        node.content = node.content.strip
      end
    end
    # remove all whitespaces between tags
    doc.to_s.gsub(/>\s+</, '><')
  end

  def beautify_html(html)
    # Add line breaks after opening and closing tags
    split = html.gsub(/(<[^>]*>)/, "\\1\n")
    # now parse html and pretty print it
    Nokogiri::HTML.fragment(split).to_xhtml(indent: 2)
  end

  match do |actual|
    @actual_normalized = normalize_html(actual)
    @expected_normalized = normalize_html(expected)
    @actual_normalized == @expected_normalized
  end

  failure_message do
    expected_beautified = beautify_html(@expected_normalized)
    actual_beautified = beautify_html(@actual_normalized)
    differences = Diffy::Diff.new(actual_beautified, expected_beautified).to_s(:text)
    <<~MSG
      --- Differences ---
      #{differences}
    MSG
  end
end
