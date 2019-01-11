require 'newspaper_works/data/fileset_helper'
require 'newspaper_works/data/path_helper'
require 'newspaper_works/data/work_derivatives'
require 'newspaper_works/data/work_files'
require 'newspaper_works/data/work_file'

module NewspaperWorks
  # Module for data access helper / adapter classes supporting, enhancing
  #   NewspaperWorks work models
  module Data
    # Handler for after_create_fileset, to be called by block subscribing to
    #   and overriding default Hyrax `:after_create_fileset` handler, via
    #   app integrating newspaper_works.
    def self.handle_after_create_fileset(file_set, user)
      handle_queued_derivative_attachments(file_set)
      # Hyrax queues this job by default, and since newspaper_works
      #   overrides the single subscriber Hyrax uses to do so, we
      #   must call this here:
      FileSetAttachedEventJob.perform_later(file_set, user)
    end

    def self.handle_queued_derivative_attachments(file_set)
      return if file_set.import_url.nil?
      work = file_set.member_of.select(&:work?)[0]
      derivatives = NewspaperWorks::Data::WorkDerivatives.of(work)
      # For now, becuase this is IO-bound operation, it makes sense to have
      #   this not be a job, but run inline:
      derivatives.commit_queued!(file_set)
    end
  end
end
