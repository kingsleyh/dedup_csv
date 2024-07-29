# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe DedupCsv do
  let(:path) { 'spec/tmp' }
  let(:previous_csv) { "#{path}/previous.csv" }
  let(:new_csv) { "#{path}/new.csv" }
  let(:target_csv) { "#{path}/delta.csv" }

  before do
    FileUtils.mkdir_p(path)
  end

  after(:all) do
    File.delete(*Dir['spec/tmp/*'])
  end

  it 'has a version number' do
    expect(DedupCsv::VERSION).not_to be nil
  end

  context 'when previous file does not exist' do
    it 'returns correct error message' do
      expect do
        DedupCsv.dedup(previous_csv, new_csv, target_csv)
      end.to raise_error('previous_csv_path: No such file or directory (os error 2)')
    end
  end

  context 'when new file does not exist' do
    let(:new_csv) { 'nonexistant.csv' }

    before do
      create_previous_csv
    end

    it 'returns correct error message' do
      expect do
        DedupCsv.dedup(previous_csv, new_csv, target_csv)
      end.to raise_error('new_csv_path: No such file or directory (os error 2)')
    end
  end

  context 'when the previous file is not a csv' do
    let(:previous_csv) { 'test.xls' }

    it 'returns correct error message' do
      expect do
        DedupCsv.dedup(previous_csv, new_csv, target_csv)
      end.to raise_error('previous_csv_path must be a csv file')
    end
  end

  context 'when the new file is not a csv' do
    let(:new_csv) { 'test.xls' }

    before do
      create_previous_csv
    end

    it 'returns correct error message' do
      expect { DedupCsv.dedup(previous_csv, new_csv, target_csv) }.to raise_error('new_csv_path must be a csv file')
    end
  end

  context 'when a file exists and it is a csv' do
    before do
      create_previous_csv
      create_new_csv_with_one_altered_row
      DedupCsv.dedup(previous_csv, new_csv, target_csv)
    end

    it 'returns a file with the correct number of rows' do
      expect(File.foreach(target_csv).count).to eq(2)
    end

    it 'returns a file with the correct row' do
      expect(CSV.read(target_csv)).to eq([%w[id col1 col2], %w[3 g g]])
    end
  end

  context 'when a new csv file exists but has empty rows' do
    before do
      create_previous_csv
      create_new_csv_with_empty_rows
      DedupCsv.dedup(previous_csv, new_csv, target_csv)
    end

    it 'returns a file with the correct number of rows and skips empty rows' do
      expect(File.foreach(target_csv).count).to eq(2)
    end
  end

  context 'when a new csv file exists but has extra carriage returns and new lines' do
    before do
      create_previous_csv
      create_new_csv_with_nl_cr
      DedupCsv.dedup(previous_csv, new_csv, target_csv)
    end

    it 'returns a file with the correct number of rows and removes extra new lines' do
      expect(File.readlines(target_csv).count).to eq(2)
    end
  end

  context 'when a previous csv file exists but has empty rows' do
    before do
      create_previous_csv
      create_previous_csv_with_empty_rows
      DedupCsv.dedup(previous_csv, new_csv, target_csv)
    end

    it 'returns a file with the correct number of rows and skips empty rows' do
      expect(File.foreach(target_csv).count).to eq(2)
    end
  end

  context 'where the headers do not match on existing files' do
    let(:new_csv) { "#{path}/bad_headers.csv" }

    before do
      create_previous_csv
      create_new_csv_with_altered_header
    end

    it 'returns correct error message' do
      expect do
        DedupCsv.dedup(previous_csv, new_csv, target_csv)
      end.to raise_error('headers of both csv files must be the same')
    end
  end

  def create_previous_csv
    CSV.open('spec/tmp/previous.csv', 'w') do |csv|
      csv << %w[id col1 col2]
      csv << %w[1 a b]
      csv << %w[3 e f]
      csv << %w[2 c d]
    end
  end

  def create_new_csv_with_one_altered_row
    CSV.open('spec/tmp/new.csv', 'w') do |csv|
      csv << %w[id col1 col2]
      csv << %w[3 g g]
      csv << %w[1 a b]
      csv << %w[2 c d]
    end
  end

  def create_new_csv_with_empty_rows
    CSV.open('spec/tmp/new_empty_rows.csv', 'w') do |csv|
      csv << %w[id col1 col2]
      csv << %w[3 g g]
      csv << ['', '', '']
      csv << %w[1 a b]
      csv << ['', '', '']
      csv << %w[2 c d]
    end
  end

  def create_previous_csv_with_empty_rows
    CSV.open('spec/tmp/previous_empty_rows.csv', 'w') do |csv|
      csv << %w[id col1 col2]
      csv << %w[1 a b]
      csv << ['', '', '']
      csv << %w[3 e f]
      csv << ['', '', '']
      csv << %w[2 c d]
    end
  end

  def create_new_csv_with_altered_header
    CSV.open('spec/tmp/bad_headers.csv', 'w') do |csv|
      csv << %w[ids sad mad]
      csv << %w[1 a b]
      csv << %w[3 e f]
      csv << %w[2 c d]
    end
  end

  def create_new_csv_with_nl_cr
    CSV.open('spec/tmp/returns.csv', 'w') do |csv|
      csv << %w[id col1 col2]
      csv << [3, "g\n\n\r", 'g']
      csv << [1, "a\n", 'b']
      csv << [2, "c\r\n", 'd']
    end
  end
end
# rubocop:enable Metrics/BlockLength
