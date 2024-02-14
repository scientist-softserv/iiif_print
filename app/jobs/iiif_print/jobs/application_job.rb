module IiifPrint
  module Jobs
    # TODO: Consider inheriting from ::Application job.  That means we would have the upstreams
    # based job behavior.
    class ApplicationJob < ::ApplicationJob
      queue_as ::IiifPrint.config.ingest_queue_name
    end
  end
end
