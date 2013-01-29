require 'spec_helper'

describe Slodown::Formatter do
  context "#sanitize_config" do
    subject { Slodown::Formatter.new('foo') }
     %w( p a span sub sup strong em div hr abbr big small ul ol li blockquote pre code h1 h2 h3 h4 h5 h6 img object param del ).each do |el|
      it "should include sane elements by default (#{el})" do
        subject.sanitize_config[:elements].should include(el)
      end
    end
    context "allows elements to be added" do
      before do
        subject.sanitize_config[:elements] << 'foo'
      end
      specify { expect{subject.sanitize_config[:elements].should include('foo') }
    end
    context "allows elements to be removed" do
      before do
        subject.sanitize_config[:elements].delete('blockquote')
      end
      specify { subject.sanitize_config[:elements].should_not include('blockquote') }
    end
  end
end
