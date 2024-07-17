# frozen_string_literal: true

RSpec.describe DedupCsv do
  it "has a version number" do
    expect(DedupCsv::VERSION).not_to be nil
  end

  it "does something useful" do
    pp DedupCsv.dedup("kings", "kings2", "kings3")
    # expect(true).to eq(true)
  end
end
