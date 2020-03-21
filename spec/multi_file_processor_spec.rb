# frozen_string_literal: true
require 'spec_helper'

describe MultiFileProcessor do
  let(:file_pattern) { TMP_DIR.join('*.csv') }
  let(:options) { {} }
  let(:process_file_proc) { Proc.new { |_| } }
  let(:multi_file_processor) { MultiFileProcessor.new(file_pattern, options) }

  context '.each' do
    subject { multi_file_processor.each { |f| process_file_proc.call(f) } }

    before(:each) do
      FileUtils.touch TMP_DIR.join('1.csv')
      FileUtils.touch TMP_DIR.join('2.csv')
    end

    it 'moves all files to done' do
      subject
      expect(File.exist?(TMP_DIR.join('1.csv.done'))).to eq(true)
      expect(File.exist?(TMP_DIR.join('2.csv.done'))).to eq(true)
    end

    describe 'failure' do
      let(:process_file_proc) { Proc.new { |file| File.basename(file) == '1.csv.inprogress' ? multi_file_processor.failed! : nil } }

      it 'moves failed files to .failed' do
        subject
        expect(File.exist?(TMP_DIR.join('1.csv.failed'))).to eq(true)
        expect(File.exist?(TMP_DIR.join('2.csv.done'))).to eq(true)
      end
    end
  end
end
