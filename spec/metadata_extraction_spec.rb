require 'spec_helper'

describe '#metadata' do
  let(:text) do
    <<-EOF.gsub(/^\t/, '')
	#+title: A document with metadata
	#+created_at: 2014-03-01 12:56:31 CET
	# The first headline

	A paragraph.
        #+with: no metadata
    EOF
  end

  let(:formatter) { Slodown::Formatter.new(text).complete }

  it 'returns metadata as a hash' do
    expect(formatter.metadata).to be_a(Hash)
  end

  it 'contains every listed key' do
    expect(formatter.metadata.keys).to match_array([:title, :created_at])
  end

  it 'contains every listed value' do
    expect(formatter.metadata.values).to match_array(['A document with metadata',
                                                      '2014-03-01 12:56:31 CET'])
  end

  it 'removes metadata from the source' do
    expect(formatter.to_s).to_not match(/created_at/)
  end

  describe 'keys occuring more than once' do
    let(:text) do
      <<-EOF.gsub(/^\t/, '')
	#+title: ignored
	#+title: foo
      EOF
    end

    it 'uses the last definition' do
      expect(formatter.metadata.fetch(:title)).to eql 'foo'
    end
  end
end
