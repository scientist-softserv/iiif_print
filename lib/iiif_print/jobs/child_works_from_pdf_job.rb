module IiifPrint
  module Jobs
    class ChildWorksFromPdfJob < IiifPrint::Jobs::ApplicationJob
      # Break a pdf into individual pages
      # @param parent_work
      # @param pdf_paths: [<Array => String>] paths to pdfs
      # @param user: [User]
      # @param admin_set_id: [<String>]
      # @param prior_pdfs: [<Integer>] count of pdfs already on parent work
      # TODO: implement prior_pdfs - currently it is always set to 0
      def perform(parent_work, pdf_paths, user, admin_set_id, prior_pdfs)
        @parent_work = parent_work
        @child_admin_set_id = admin_set_id
        child_model = @parent_work.iiif_print_config.pdf_split_child_model

        # handle each input pdf
        pdf_paths.each_with_index do |path, pdf_idx|
          split_pdf(path, pdf_idx, user, prior_pdfs, child_model, number_of_pdfs: pdf_paths.size)
        end

        # Link newly created child works to the parent
        # @param user: [User] user
        # @param parent_id: [<String>] parent work id
        # @param parent_model: [<String>] parent model
        # @param child_model: [<String>] child model
        IiifPrint::Jobs::CreateRelationshipsJob.set(wait: 10.minutes).perform_later(
          user: user,
          parent_id: @parent_work.id,
          parent_model: @parent_work.class.to_s,
          child_model: child_model.to_s
        )

        # TODO: clean up image_files and pdf_paths
      end

      private

      # rubocop:disable Metrics/ParameterLists
      def split_pdf(path, pdf_idx, user, prior_pdfs_count, child_model, number_of_pdfs:)
        image_files = @parent_work.iiif_print_config.pdf_splitter_service.new(path).to_a
        return if image_files.blank?

        pdf_sequence = pdf_idx + prior_pdfs_count
        prepare_import_data(pdf_sequence, image_files, user, number_of_pdfs: number_of_pdfs)

        # submit the job to create all the child works for one PDF
        # @param [User] user
        # @param [Hash<String => String>] titles
        # @param [Hash<String => String>] resource_types (optional)
        # @param [Array<String>] uploaded_files Hyrax::UploadedFile IDs
        # @param [Hash] attributes attributes to apply to all works, including :model
        # @param [Hyrax::BatchCreateOperation] operation
        operation = Hyrax::BatchCreateOperation.create!(
          user: user,
          operation_type: "PDF Batch Create"
        )
        BatchCreateJob.perform_later(user,
                                     @child_work_titles,
                                     {},
                                     @uploaded_files,
                                     attributes.merge!(model: child_model.to_s).with_indifferent_access,
                                     operation)
      end
      # rubocop:enable Metrics/ParameterLists

      # rubocop:disable Metrics/MethodLength
      def prepare_import_data(pdf_sequence, image_files, user, number_of_pdfs:)
        @uploaded_files = []
        @child_work_titles = {}
        pdf_number_of_pages = image_files.size
        image_files.each_with_index do |image_path, idx|
          file_id = create_uploaded_file(user, image_path).to_s

          file_title = Iiif.config.child_file_title_generator_function.call(
            parent_work: parent_work,
            pdf_number: pdf_sequence,
            page_number: idx,
            pdf_padding: number_of_digits(nbr: number_of_pdfs),
            page_padding: number_of_digits(nbr: pdf_number_of_pages))

          # file_title = set_title(@parent_work.title.first,
          #                        pdf_sequence,
          #                        idx,
          #                        pdf_pad_zero: number_of_digits(nbr: number_of_pdfs),
          #                        page_pad_zero: number_of_digits(nbr: pdf_number_of_pages))
          @uploaded_files << file_id
          @child_work_titles[file_id] = file_title
          # save child work info to create the member relationships
          PendingRelationship.create!(child_title: file_title,
                                      parent_id: @parent_work.id,
                                      child_order: sort_order(pdf_sequence,
                                                              idx,
                                                              pdf_pad_zero: number_of_digits(nbr: number_of_pdfs),
                                                              page_pad_zero: number_of_digits(nbr: pdf_number_of_pages)))
        end
      end
      # rubocop:enable Metrics/MethodLength

      def sort_order(pdf_sequence, idx, pdf_pad_zero:, page_pad_zero:)
        padded_pdf = (pdf_sequence + 1).to_s.rjust(pdf_pad_zero, "0")
        padded_page = (idx + 1).to_s.rjust(page_pad_zero, "0")
        "#{padded_pdf}-#{padded_page}"
      end

      def number_of_digits(nbr:)
        nbr.to_s.size
      end

      def create_uploaded_file(user, path)
        uf = Hyrax::UploadedFile.new
        uf.user_id = user.id
        uf.file = CarrierWave::SanitizedFile.new(path)
        uf.save!
        uf.id
      end

      def set_title(title, pdf_sequence, idx, pdf_pad_zero:, page_pad_zero:)
        # TODO: prior_pdfs may cause issues in the future
        pdf_nbr = (pdf_sequence + 1).to_s.rjust(pdf_pad_zero, "0")
        page_nbr = (idx + 1).to_s.rjust(page_pad_zero, "0")
        pdf_index = "Pdf #{pdf_nbr}"
        page_number = "Page #{page_nbr}"
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
