# frozen_string_literal: true

# Encapsulates methods used for pdf splitting into child works
module IiifPrint
  module SplitPdfs
    class ChildWorkCreationFromPdfService
      # Load an array of paths to pdf files
      # @param [Array > Hyrax::Upload file ids]
      # @return [Array > String] file paths to temp directory
      def self.pdf_paths(files:)
        return [] if files.all?(&:empty?) # assumes an array

        upload_ids = filter_file_ids(files)
        return [] if upload_ids.empty?

        uploads = Hyrax::UploadedFile.find(upload_ids)
        paths = uploads.map(&method(:upload_path))
        pdfs_only_for(paths)
      end

      # Is child work splitting defined for model?
      # @param [GenericWork, etc] A valid type of hyrax work
      # @return [Boolean]
      def self.iiif_print_split?(work:)
        # defined only if work has include IiifPrint.model_configuration with pdf_split_child_model
        return true if work.try(:iiif_print_config)&.pdf_split_child_model
        false
      end

      # Are there any PDF files?
      # @param [Array > String] paths to PDFs
      # @return [Boolean]
      def self.pdfs?(paths:)
        pdf_paths = pdfs_only_for(paths)
        return false unless pdf_paths.count.positive?
        true
      end

      # Submit the job to split PDF into child works
      # @param [GenericWork, etc] A valid type of hyrax work
      # @param [Array<String>] paths to PDF attachments
      # @param [User] user
      # @param [Integer] number of pdfs already on existing work's filesets (not yet implemented)
      def self.queue_job(work:, file_locations:, user:, admin_set_id:)
        work.iiif_print_config.pdf_splitter_job.perform_later(
          work,
          file_locations,
          user,
          admin_set_id,
          count_existing_pdfs(work)
        )
      end

      def self.filter_file_ids(input)
        Array.wrap(input).select(&:present?)
      end

      # Given Hyrax::Upload object, return path to file on local filesystem
      def self.upload_path(upload)
        # so many layers to this onion:
        upload.file.file.file
      end

      # TODO: implement a method to count existing PDFs on a work to support
      #       adding more PDFs to an existing work.
      def self.count_existing_pdfs(_work)
        0
      end

      # TODO: Consider other methods to identify a PDF file.
      #       This sub-selection may need to be moved to use mimetype if there
      #       is a need to support paths not ending in .pdf (i.e. remote_urls)
      def self.pdfs_only_for(paths)
        paths.select { |path| path.end_with?('.pdf', '.PDF') }
      end
    end
  end
end
