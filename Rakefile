# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rb_sys/extensiontask'

task build: :compile

spec = Bundler.load_gemspec('dedup_csv.gemspec')
# spec.requirements.clear
# spec.required_ruby_version = nil
# spec.required_rubygems_version = nil
# spec.extensions.clear
# spec.files -= Dir['ext/**/*']

Rake::ExtensionTask.new('dedup_csv', spec) do |c|
  c.lib_dir = 'lib/dedup_csv'
  c.cross_compile = true
  c.cross_platform = %w[
    aarch64-linux
    arm64-darwin
    x64-mingw-ucrt
    x64-mingw32
    x86_64-darwin
    x86_64-linux
    x86_64-linux-musl
  ]
end

RbSys::ExtensionTask.new('dedup_csv') do |ext|
  ext.lib_dir = 'lib/dedup_csv'
end

task default: %i[compile spec rubocop]
