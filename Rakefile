# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rb_sys/extensiontask'

task build: :compile

RbSys::ExtensionTask.new('dedup_csv') do |ext|
  ext.lib_dir = 'lib/dedup_csv'
end

task default: %i[compile spec rubocop]
