##
# @see https://github.com/samvera/hyrax/wiki/Hyrax's-Event-Bus-(Hyrax::Publisher)
# @see https://www.rubydoc.info/gems/hyrax/Hyrax/Publisher
# @see https://dry-rb.org/gems/dry-events
module IiifPrint
  class Listener
    ##
    # Responsible for conditionally enqueuing the creation of child works from a PDF.
    #
    # @param event [#[]] a hash like construct with keys :user and :file_set
    # @param service [#conditionally_enqueue]
    #
    # @see Hyrax::WorkUploadsHandler
    def on_file_characterized(event, service: IiifPrint::SplitPdfs::ChildWorkCreationFromPdfService)
      file_set = event[:file_set]
      return false unless file_set
      return false unless file_set.file_set?
      return false unless file_set.original_file.pdf?

      work = IiifPrint.parent_for(file_set)
      # A short-circuit to avoid fetching the underlying file.
      return false unless work

      user = work.depositor
      # TODO: Verify that this is the correct thing to be sending off for conditional enquing.  That
      # will require a more involved integration test.
      file = file_set.original_file
      service.conditionally_enqueue(file_set: file_set, work: work, file: file, user: user)
    end

    ##
    # Responsible for setting the is_child flag on the work when a child work is created.
    #
    # @param event [#[]] a hash like construct with :object key
    def on_object_membership_updated(event)
      object = event[:object]
      return unless object.respond_to?(:iiif_print_config?) && object.iiif_print_config?

      Hyrax.custom_queries.find_child_works(resource: object).each do |child_work|
        next if child_work.is_child
        child_work.is_child = true
        Hyrax.persister.save(resource: child_work)
        Hyrax.index_adapter.save(resource: child_work)
      end
    end
  end
end
