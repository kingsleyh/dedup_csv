# frozen_string_literal: true

# load native extension
begin
  ruby_version = /(\d+\.\d+)/.match(RUBY_VERSION)
  require_relative "dedup_csv/#{ruby_version}/dedup_csv"
rescue LoadError
  require_relative 'dedup_csv/dedup_csv'
end

require_relative 'dedup_csv/version'

module DedupCsv
end
