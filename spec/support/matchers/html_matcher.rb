RSpec::Matchers.define :match_html do |expected|
  def normalize_html(html)
    # we try and strip all whitespaces and new lines
    doc = Nokogiri::HTML.fragment(html.strip)
    # strip all attributes values
    doc.traverse do |node|
      if node.respond_to?(:attributes)
        node.attributes.each do |name, attr|
          attr.value = attr.value.strip
        end
      end
    end
    # remove all whitespaces between tags
    doc.to_s.gsub(/>\s+</, '><')
  end

  def beautify_html(html)
    # cf https://stackoverflow.com/a/7839017
    Nokogiri::XML(html, &:noblanks).to_s.sub('<?xml version="1.0"?>', '')
  end

  match do |actual|
    @actual = actual
    normalize_html(expected) == normalize_html(actual)
  end

  failure_message do
    <<~MSG
      expected HTML to match
      Expected:
      #{beautify_html(expected)}

      Got:
      #{beautify_html(@actual)}
    MSG
  end
end
