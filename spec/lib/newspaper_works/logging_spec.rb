require 'spec_helper'

describe NewspaperWorks::Logging do
  describe "mixin logging module" do
    let(:klass) do
      Class.new do
        include NewspaperWorks::Logging
      end
    end

    let(:loggable) { klass.new }

    let(:configured) do
      obj = loggable
      # expectation is that this is called by consuming class constructor:
      obj.configure_logger('ingest-test')
      obj
    end

    it "requires configuration by consuming class" do
      name = 'random_testing_logname'
      expect(loggable.instance_variable_get(:@logger)).to be_nil
      expect(described_class.configured).not_to include name
      loggable.configure_logger(name)
      expect(loggable.instance_variable_get(:@logger)).not_to be_nil
      expect(described_class.configured).to include name
    end

    it "logs formatted message to rails logger with write_log" do
      message = "FYI: heads-up, this is a message"
      expect(Rails.logger).to receive(:add).with(
        Logger::INFO,
        configured.message_format(message),
        nil
      )
      configured.write_log(message)
    end

    it "writes to named log file" do
      # need to reset global de-dupe state for additional logger, just for
      #   purposes of this test
      described_class.configured = []
      message = "Instant coffee"
      named_log = configured.instance_variable_get(:@named_log)
      expect(named_log).to receive(:add).with(
        Logger::INFO,
        configured.message_format(message),
        nil
      )
      configured.write_log(message)
    end
  end
end
