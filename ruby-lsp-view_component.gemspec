# frozen_string_literal: true

require_relative "lib/ruby_lsp_view_component/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-lsp-view_component"
  spec.version = RubyLsp::RubyLspViewComponent::VERSION
  spec.authors = ["Daniel Retamal"]
  spec.email = ["daniel.retamal.ahumada@gmail.com"]

  spec.summary = "Ruby LSP add-on for ViewComponent"
  spec.description = "Adds a CodeLens to ViewComponent classes that jumps to their templates"
  spec.homepage = "https://github.com/daniel-retamal/ruby-lsp-view_component"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency("ruby-lsp", "~> 0.26.0")
end
