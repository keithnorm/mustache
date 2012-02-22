$LOAD_PATH.unshift File.dirname(__FILE__)
require 'helper'

class ParserTest < Test::Unit::TestCase
  def test_parser
    lexer = Mustache::Parser.new
    tokens = lexer.compile(<<-EOF)
<h1>{{header}}</h1>
{{#items}}
{{#first}}
  <li><strong>{{ truncate name count=10 ellipsis="..." }}</strong></li>
{{/first}}
{{#link}}
  <li><a href="{{url}}">{{name}}</a></li>
{{/link}}
{{/items}}

{{#empty}}
<p>The list is empty.</p>
{{/empty}}
EOF

    expected = [:multi,
     [:static, "<h1>"],
     [:mustache, :etag, [:mustache, :fetch, ["header"]]],
     [:static, "</h1>\n"],
     [:mustache,
      :section,
      [:mustache, :fetch, ["items"]],
      [:multi,
       [:mustache,
        :section,
        [:mustache, :fetch, ["first"]],
        [:multi,
         [:static, "  <li><strong>"],
         [:mustache,
          :etag,
          [:mustache, :fetch, ["truncate"]],
          [:mustache, :fetch, ["name"]],
          [:hash,
           [[[:static, "count"], [:number, "10"]],
            [[:static, "ellipsis"], [:static, "..."]]]]],
         [:static, "</strong></li>\n"]],
        "  <li><strong>{{ truncate name count=10 ellipsis=\"...\" }}</strong></li>\n",
        ["{{", "}}"]],
       [:mustache,
        :section,
        [:mustache, :fetch, ["link"]],
        [:multi,
         [:static, "  <li><a href=\""],
         [:mustache, :etag, [:mustache, :fetch, ["url"]]],
         [:static, "\">"],
         [:mustache, :etag, [:mustache, :fetch, ["name"]]],
         [:static, "</a></li>\n"]],
        "  <li><a href=\"{{url}}\">{{name}}</a></li>\n",
        ["{{", "}}"]]],
      "{{#first}}\n  <li><strong>{{ truncate name count=10 ellipsis=\"...\" }}</strong></li>\n{{/first}}\n{{#link}}\n  <li><a href=\"{{url}}\">{{name}}</a></li>\n{{/link}}\n",
      ["{{", "}}"]],
     [:static, "\n"],
     [:mustache,
      :section,
      [:mustache, :fetch, ["empty"]],
      [:multi, [:static, "<p>The list is empty.</p>\n"]],
    "<p>The list is empty.</p>\n",
    ["{{", "}}"]]]

    assert_equal expected, tokens
  end

  def test_raw_content_and_whitespace
    lexer = Mustache::Parser.new
    tokens = lexer.compile("{{#list}}\t{{/list}}")

    expected = [:multi,
      [:mustache,
        :section,
        [:mustache, :fetch, ["list"]],
        [:multi, [:static, "\t"]],
        "\t",
        %w[{{ }}]]]

    assert_equal expected, tokens
  end
end
