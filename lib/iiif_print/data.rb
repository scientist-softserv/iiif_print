require 'iiif_print/data/fileset_helper'
require 'iiif_print/data/path_helper'
require 'iiif_print/data/work_derivatives'
require 'iiif_print/data/work_files'
require 'iiif_print/data/work_file'

module IiifPrint
  # Module for data access helper / adapter classes supporting, enhancing
  #   IiifPrint work models
  module Data
    # Handler for after_create_fileset, to be called by block subscribing to
    #   and overriding default Hyrax `:after_create_fileset` handler, via
    #   app integrating iiif_print.
    def self.handle_after_create_fileset(file_set, user)
      handle_queued_derivative_attachments(file_set)
      # Hyrax queues this job by default, and since iiif_print
      #   overrides the single subscriber Hyrax uses to do so, we
      #   must call this here:
      FileSetAttachedEventJob.perform_later(file_set, user)
      work = file_set.member_of[0]
      # Hyrax CreateWithRemoteFilesActor has glaring omission re: this job,
      #   so we call it here, once we have a fileset to copy permissions to.
      InheritPermissionsJob.perform_later(work) unless work.nil?
    end

    def self.handle_queued_derivative_attachments(file_set)
      return if file_set.import_url.nil?
      work = file_set.member_of.find(&:work?)
      derivatives = IiifPrint::Data::WorkDerivatives.of(work)
      # For now, becuase this is IO-bound operation, it makes sense to have
      #   this not be a job, but run inline:
      derivatives.commit_queued!(file_set)
    end
  end
end
