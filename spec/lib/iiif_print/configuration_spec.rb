require 'spec_helper'

RSpec.describe IiifPrint::Configuration do
  subject { described_class.new }

  it { is_expected.to respond_to(:work_types_for_derivative_service) }

  describe '#work_types_for_derivative_service' do
    subject { described_class.new.work_types_for_derivative_service }
    it { is_expected.to be_an Array }
  end
end
