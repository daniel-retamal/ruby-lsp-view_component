## [Unreleased]

## [0.3.0]

- `Jump to template` opens the inherited templates of a component without its own: those of the nearest ancestor that has them, unless a class in between defines `call`.

## [0.2.1]

- Drop the gemspec dependency on `ruby-lsp`. The add-on still declares `~> 0.26.0` with `depend_on_ruby_lsp!`, so a newer Ruby LSP no longer blocks `bundle update`: the add-on skips activation with a warning until it supports that version.

## [0.2.0]

- `Jump to template` also shows on components that need a template and have none. It opens the missing `.html.erb` next to the class, and VS Code offers to create it.

## [0.1.0]

- `Jump to template` CodeLens on ViewComponent classes. It opens the component template, or a picker when the component has variants or sub-templates.
