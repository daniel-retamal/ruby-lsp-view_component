# frozen_string_literal: true

module RubyLsp
  module RubyLspViewComponent
    class CodeLens
      include Requests::Support::Common

      TEMPLATE_EXTENSIONS = "{erb,haml,slim}"

      #: (ResponseBuilders::CollectionResponseBuilder[Interface::CodeLens], URI::Generic, Prism::Dispatcher) -> void
      def initialize(response_builder, uri, dispatcher)
        @response_builder = response_builder
        @path = uri.to_standardized_path #: String?
        @seen_class = false
        dispatcher.register(self, :on_class_node_enter) if @path&.end_with?(".rb")
      end

      #: (Prism::ClassNode) -> void
      def on_class_node_enter(node)
        return if @seen_class

        @seen_class = true
        uris = templates.map { |path| URI::Generic.from_path(path: path).to_s }
        return if uris.empty?

        @response_builder << create_code_lens(
          node,
          title: "Jump to template",
          command_name: "rubyLsp.openFile",
          arguments: [uris],
          data: { type: "file" },
        )
      end

      private

      #: -> Array[String]
      def templates
        path = @path #: as !nil
        dir = File.dirname(path)
        name = File.basename(path, ".rb")
        Dir.glob(["#{name}.*#{TEMPLATE_EXTENSIONS}", "#{name}/*.#{TEMPLATE_EXTENSIONS}"], base: dir)
          .reject { |file| nested_component?(dir, file) }
          .sort_by { |file| File.basename(file).start_with?("#{name}.") ? [0, file.length, file] : [1, 0, file] }
          .map { |file| File.join(dir, file) }
      end

      #: (String, String) -> bool
      def nested_component?(dir, file)
        File.dirname(file) != "." &&
          File.exist?(File.join(dir, File.dirname(file), "#{File.basename(file).split(".").first}.rb"))
      end
    end
  end
end
