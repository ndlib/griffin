require 'spec_helper'

describe SortableTitleConverter do
  let(:title) { "A Title"}
  subject { described_class.new(title) }

  describe '#original_title' do
    let(:title) { "Original Title" }
    it 'is the original title' do
      expect(subject.original_title).to eq("Original Title")
    end
  end

  describe '#converted_title' do
    it 'returns the raw title' do
      subject.stub(:original_title).and_return('raw_title')
      expect(subject.converted_title).to eq('raw_title')
    end

    it 'removes leading and trailing whitespace' do
      subject.stub(:original_title).and_return(' raw_title ')
      expect(subject.converted_title).to eq('raw_title')
    end

    it 'makes the title lowercase' do
      subject.stub(:original_title).and_return('Upper Title')
      expect(subject.converted_title).to eq('upper title')
    end

    it 'removes quotes from the beginning' do
      subject.stub(:original_title).and_return('"raw_title"')
      expect(subject.converted_title).to eq('raw_title"')
    end

    %w(a an the).each do |article|
      it "removes leading '#{article}'" do
        subject.stub(:original_title).and_return("#{article} article")
        expect(subject.converted_title).to eq('article')
      end
    end
  end

  describe 'self' do
    subject { described_class }

    describe '#convert' do
      it 'returns the converted_title' do
        expect(subject.convert('A Title')).to eq('title')
      end
    end
  end
end
