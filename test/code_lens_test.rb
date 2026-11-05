# frozen_string_literal: true

require "test_helper"

class CodeLensTest < Minitest::Test
  include RubyLsp::TestHelper

  COMPONENTS = File.expand_path("fixtures/components", __dir__)

  def test_jumps_to_sibling_templates_main_first
    lens = lenses("sibling_component.rb").first

    assert_equal(
      ["rubyLsp.openFile", [uri("sibling_component.html.erb"), uri("sibling_component.html+phone.erb")], 0],
      [lens.command.command, lens.command.arguments.first, lens.range.start.line],
    )
  end

  def test_jumps_to_sidecar_templates_from_the_outermost_class_only
    lenses = lenses("sidecar_component.rb")

    assert_equal(
      [[[uri("sidecar_component/sidecar_component.html.haml"), uri("sidecar_component/list.html.erb")]], [1]],
      [lenses.map { |lens| lens.command.arguments.first }, lenses.map { |lens| lens.range.start.line }],
    )
  end

  def test_nested_component_gets_its_own_template
    assert_equal(
      [[uri("sidecar_component/item_component.html.erb")]],
      lenses("sidecar_component/item_component.rb").map { |lens| lens.command.arguments.first },
    )
  end

  def test_jumps_to_the_missing_sibling_template_when_the_component_needs_one
    assert_equal(
      [[uri("missing_component.html.erb")]],
      lenses("missing_component.rb").map { |lens| lens.command.arguments.first },
    )
  end

  def test_no_lens_when_the_component_does_not_need_a_template
    files = ["inline_component.rb", "inherited_component.rb", "abstract_component.rb", "missing.rb"]

    assert_empty(files.flat_map { |file| lenses(file) })
  end

  private

  def lenses(file)
    path = File.join(COMPONENTS, file)
    with_server(File.read(path), URI::Generic.from_path(path: path)) do |server, uri|
      index = server.global_state.index
      index.index_single(URI("file:///view_component.rb"), "module ViewComponent; class Base; end; end")
      (Dir.glob("**/*.rb", base: COMPONENTS) - [file]).each do |fixture|
        fixture_path = File.join(COMPONENTS, fixture)
        index.index_single(URI::Generic.from_path(path: fixture_path), File.read(fixture_path))
      end
      server.process_message(id: 1, method: "textDocument/codeLens", params: { textDocument: { uri: uri } })
      pop_result(server).response.select { |lens| lens.command.title == "Jump to template" }
    end
  end

  def uri(file)
    URI::Generic.from_path(path: File.join(COMPONENTS, file)).to_s
  end
end
