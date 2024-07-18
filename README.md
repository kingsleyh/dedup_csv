# DedupCsv

Given 2 CSV files, this gem will create a third CSV file that contains rows from the first CSV file that are not present in the second CSV file.

## Installation

```bash
gem install dedup_csv
```

## Usage

```irb
require 'dedup_csv'
DedupCsv.dedup('file1.csv', 'file2.csv', 'output.csv')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kingsleyh/dedup_csv.
