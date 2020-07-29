module NewspaperWorks
  module Ingest
    module NDNP
      # Ingester for reel/container, given reel source data
      #   and required publication (NewspaperTitle) asset.
      #   Responsibile for creating/finding container, linking
      #   to (parent) publication and (child) pages.
      class ContainerIngester
        include NewspaperWorks::Ingest::NDNP::NDNPAssetHelper

        attr_accessor :source, :target, :publication, :opts

        # Create ingester in context of source reel data, NewspaperTitle
        # @param source [NewspaperWorks::Ingest::NDNP::ContainerIngest]
        # @param publication [NewspaperTitle] Required publication to link to
        # @param opts [Hash]
        #   ingest options, e.g. administrative metadata
        def initialize(source, publication, opts = {})
          @source = source
          @publication = publication
          @opts = opts
          # initially nil, populate w/ NewspaperContainer object via .ingest
          @target = nil
        end

        def ingest
          find_or_create_container
          link_publication
        end

        # Link a page to target container
        # @param page [NewspaperPage]
        def link(page)
          @target.ordered_members << page
          # save each link attempt (for now no deferring/bundling)
          @target.save!
        end

        def find_or_create_container
          @target = find_container
          create_container if @target.nil?
        end

        private

        def metadata
          @source.metadata
        end

        def find_container
          NewspaperContainer.where(identifier: metadata.reel_number).first
        end

        def create_container
          @target = NewspaperContainer.create
          copy_metadata
          assign_administrative_metadata
          @target.save!
        end

        def copy_metadata
          reel_number = metadata.reel_number
          @target.identifier = [reel_number]
          @target.title = ["Microform reel (#{reel_number})"]
          copy_fields = [
            :held_by,
            :publication_date_start,
            :publication_date_end
          ]
          copy_fields.each do |fieldname|
            value = metadata.send(fieldname.to_s)
            @target.send("#{fieldname}=", value)
          end
        end

        def link_publication
          return unless @target.publication.nil?
          @publication.members << @target
          @publication.save!
        end
      end
    end
  end
end
