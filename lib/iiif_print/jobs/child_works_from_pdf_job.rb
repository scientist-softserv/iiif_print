module IiifPrint
  module Jobs
    # Break a pdf into individual pages
    class ChildWorksFromPdfJob < IiifPrint::Jobs::ApplicationJob
      def perform(parent_work, pdf_paths, user, admin_set_id, prior_pdfs)
        @parent_work = parent_work
        @child_admin_set_id = admin_set_id
        prior_pdfs_count = prior_pdfs
        child_model = @parent_work.iiif_print_config.pdf_split_child_model
        pdf_splitter_service = @parent_work.iiif_print_config.pdf_splitter_service
        @child_count = 0

        # handle each input pdf
        pdf_paths.each_with_index do |path, pdf_idx|
          image_files = pdf_splitter_service.new(path).to_a

          next if image_files.blank?
          operation = Hyrax::BatchCreateOperation.create!(
            user: user,
            operation_type: "PDF Batch Create")

          pdf_sequence = pdf_idx + prior_pdfs_count
          # Load the data that the job needs based on the image_files
          prepare_import_data(pdf_sequence, image_files, user)
          
          # submit the job to create child works for one PDF
          # @param [User] user
          # @param [Hash<String => String>] titles
          # @param [Hash<String => String>] resource_types (optional)
          # @param [Array<String>] uploaded_files Hyrax::UploadedFile IDs
          # @param [Hash] attributes attributes to apply to all works, including :model
          # @param [Hyrax::BatchCreateOperation] operation
          BatchCreateJob.perform_later(
            user,
            @child_work_titles,
            {},
            @uploaded_files,
            attributes.merge!(model: child_model.to_s).with_indifferent_access,
            operation)
        end

        # Link newly created child works to the parent
        # @param user: [User] user
        # @param parent_id: [<String>] parent work id
        # @param parent_model: [<String>] parent model
        # @param child_count: [<Integer>] count of children
        # @param child_model: [<String>] child model
        IiifPrint::Jobs::CreateRelationshipsJob.set(wait: 10.minutes).perform_later(
          user: user,
          parent_id: @parent_work.id,
          parent_model: @parent_work.class.to_s,
          child_count: @child_count,
          child_model: child_model.to_s
        )

        # TODO: clean up image_files and pdf_paths
      end

      private

      def prepare_import_data(pdf_sequence, image_files, user)
        @uploaded_files = []
        @child_work_titles = {}
        image_files.each_with_index do |image_path, idx|
          file_id = create_uploaded_file(user, image_path).to_s
          file_title = set_title(@parent_work.title.first, pdf_sequence, idx)
          @uploaded_files << file_id
          @child_work_titles[file_id] = file_title
          # save child work info to create the member relationships
          PendingRelationship.create!(
            child_title: file_title,
            parent_id: @parent_work.id,
            order: sort_order(pdf_sequence, idx))
        end
        @child_count += @uploaded_files.count
      end

      def sort_order(pdf_sequence, idx)
        "#{pdf_sequence} #{idx}"
      end

      def create_uploaded_file(user, path)
        uf = Hyrax::UploadedFile.new
        uf.user_id = user.id
        uf.file = CarrierWave::SanitizedFile.new(path)
        uf.save!
        uf.id
      end

      def set_title(title, pdf_sequence, idx)
        pdf_index = "Pdf Nbr #{pdf_sequence + 1}"
        page_number = "Page #{idx + 1}"
        "#{title}: #{pdf_index}, #{page_number}"
      end

      # TODO: what attributes do we need to fill in from the parent work? What about AllinsonFlex?
      def attributes
        {
          admin_set_id: @child_admin_set_id.to_s,
          creator: @parent_work.creator.to_a,
          rights_statement: @parent_work.rights_statement.to_a,
          visibility: @parent_work.visibility.to_s
        }
      end
    end
  end
end
