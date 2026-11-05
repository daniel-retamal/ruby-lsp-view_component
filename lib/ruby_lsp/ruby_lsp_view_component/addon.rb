# frozen_string_literal: true

require "ruby_lsp/addon"
require_relative "../../ruby_lsp_view_component/version"
require_relative "code_lens"

RubyLsp::Addon.depend_on_ruby_lsp!("~> 0.26.0")

module RubyLsp
  module RubyLspViewComponent
    class Addon < ::RubyLsp::Addon
      # @override
      #: (GlobalState, Thread::Queue) -> void
      def activate(global_state, outgoing_queue); end

      # @override
      #: -> void
      def deactivate; end

      # @override
      #: -> String
      def name
        "Ruby LSP ViewComponent"
      end

      # @override
      #: -> String
      def version
        VERSION
      end

      # @override
      #: (ResponseBuilders::CollectionResponseBuilder[Interface::CodeLens], URI::Generic, Prism::Dispatcher) -> void
      def create_code_lens_listener(response_builder, uri, dispatcher)
        CodeLens.new(response_builder, uri, dispatcher)
      end
    end
  end
end
