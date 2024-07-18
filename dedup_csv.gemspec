# frozen_string_literal: true

require_relative 'lib/dedup_csv/version'

Gem::Specification.new do |spec|
  spec.name = 'dedup_csv'
  spec.version = DedupCsv::VERSION
  spec.authors = ['kingsley.hendrickse']
  spec.email = ['kingsley.hendrickse@patchwork.health']

  spec.summary = 'Fast CSV deduplicator'
  spec.description = 'Given 2 CSV files, remove all rows from the second CSV that are present in the first CSV.'
  spec.homepage = 'http://github.com/kingsleyh/dedup_csv'
  spec.required_ruby_version = '>= 2.6.0'
  spec.required_rubygems_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'http://github.com/kingsleyh/dedup_csv'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/dedup_csv/Cargo.toml']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
