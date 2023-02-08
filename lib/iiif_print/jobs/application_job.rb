module IiifPrint
  module Jobs
    # TODO: Consider inheriting from ::Application job.  That means we would have the upstreams
    # based job behavior.
    class ApplicationJob < ActiveJob::Base
    end
  end
end
