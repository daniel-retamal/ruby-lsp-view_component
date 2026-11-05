# frozen_string_literal: true

module RubyLsp
  module RubyLspViewComponent
    class CodeLens
      include Requests::Support::Common

      TEMPLATE_EXTENSIONS = "{erb,haml,slim}"
      NO_TEMPLATE_CALLS = [:abstract!, :erb_template, :haml_template, :slim_template].freeze

      #: (ResponseBuilders::CollectionResponseBuilder[Interface::CodeLens], URI::Generic, Prism::Dispatcher, RubyIndexer::Index) -> void
      def initialize(response_builder, uri, dispatcher, index)
        @response_builder = response_builder
        @index = index
        @path = uri.to_standardized_path #: String?
        @nesting = [] #: Array[String]
        @class_node = nil #: Prism::ClassNode?
        return unless @path&.end_with?(".rb")

        dispatcher.register(self, :on_module_node_enter, :on_module_node_leave, :on_class_node_enter, :on_class_node_leave)
      end

      #: (Prism::ModuleNode) -> void
      def on_module_node_enter(node)
        @nesting << node.constant_path.slice
      end

      #: (Prism::ModuleNode) -> void
      def on_module_node_leave(node)
        @nesting.pop
      end

      #: (Prism::ClassNode) -> void
      def on_class_node_enter(node)
        @class_node ||= node
      end

      #: (Prism::ClassNode) -> void
      def on_class_node_leave(node)
        return unless node.equal?(@class_node)

        path = @path #: as !nil
        paths = templates(path)
        paths = ["#{path.delete_suffix(".rb")}.html.erb"] if paths.empty? && needs_template?(node)
        return if paths.empty?

        @response_builder << create_code_lens(
          node,
          title: "Jump to template",
          command_name: "rubyLsp.openFile",
          arguments: [paths.map { |path| URI::Generic.from_path(path: path).to_s }],
          data: { type: "file" },
        )
      end

      private

      #: (Prism::ClassNode) -> bool
      def needs_template?(node)
        name = [*@nesting, node.constant_path.slice].join("::").delete_prefix("::")
        ancestors = @index.linearized_ancestors_of(name)
        base = ancestors.index("ViewComponent::Base")
        return false unless base
        return false if @index.resolve_method("call", name)
        return false if (ancestors.take(base) - [name]).any? { |ancestor| inherited_template?(ancestor) }

        Array(node.body&.child_nodes).none? do |child|
          child.is_a?(Prism::CallNode) && child.receiver.nil? && NO_TEMPLATE_CALLS.include?(child.name)
        end
      rescue RubyIndexer::Index::NonExistingNamespaceError
        false
      end

      #: (String) -> bool
      def inherited_template?(ancestor)
        @index[ancestor]&.any? { |entry| entry.file_path && templates(entry.file_path).any? } || false
      end

      #: (String) -> Array[String]
      def templates(path)
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
