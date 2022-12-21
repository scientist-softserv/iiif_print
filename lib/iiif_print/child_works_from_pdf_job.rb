module IiifPrint
  # Break a pdf into individual pages
  class ChildWorksFromPdfJob < IiifPrint::ApplicationJob
    def perform(parent_work, pdf_paths, user, admin_set_id)
      @parent_work = parent_work
      child_depositor = user 
      @child_admin_set = admin_set_id
      child_model = @parent_work.iiif_print_config.pdf_split_child_model
      pdf_splitter_service = @parent_work.iiif_print_config.pdf_splitter_service

      # handle each input pdf
      pdf_paths.each_with_index do |path, pdf_idx|
        image_files = pdf_splitter_service.new(path).to_a

        next if image_files.blank?
        operation = Hyrax::BatchCreateOperation.create!(
          user: child_depositor,
          operation_type: "PDF Batch Create")

        # Load the data that the job needs
        prepare_import_data(pdf_idx, @parent_work, image_files, user)
        # submit the job

        BatchCreateJob.perform_later(
          @child_depositor,
          { titles: @child_work_titles },
          { resource_types: nil },
          { uploaded_files: @uploaded_files },
          attributes.to_h.merge!(model: child_model),
          operation)
      end

      # TODO: clean up image_files and pdf_paths
    end

    private

    def prepare_import_data(pdf_idx, parent, image_files, user)
      @uploaded_files = []
      @child_work_titles = []

      image_files.each_with_index do |image_path, idx|
        @uploaded_files << create_uploaded_file(user, image_path)
        @child_work_titles << set_title(parent.title, pdf_idx, idx)
      end
    end

    def create_uploaded_file(user, path)
      uf = Hyrax::UploadedFile.new
      uf.user_id = user.id
      uf.file = CarrierWave::SanitizedFile.new(path)
      uf.save!
    end

    def set_title(title, pdf_idx, idx)
      pdf_index = pdf_idx > 0 ? "Pdf Nbr #{pdf_idx+1}," : nil
      page_number = "Page #{idx+1}"
      "#{title}: #{pdf_index} #{page_number}"
    end

    def attributes
      {
        admin_set_id: @child_admin_set,
        parent_id: @parent_work.id,
        creator: @parent_work.creator,
        rights_statement: @parent_work.rights_statement,
        visibility: @parent_work.visibility
      }
    end
  end
end
