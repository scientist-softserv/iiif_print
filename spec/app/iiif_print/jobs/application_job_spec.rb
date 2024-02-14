# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IiifPrint::Jobs::ApplicationJob do
  subject(:instance) { described_class.new }
  describe '#queue_name' do
    subject { instance.queue_name.to_s }

    # Yes, the queue_as can support a proc, but our default assumption is a symbol, so let's
    # favor that assumption.
    it { is_expected.to eq IiifPrint.config.ingest_queue_name.to_s }
  end
end
