module NewspaperWorks
  class Configuration
    # 'publication_unique_id' configs used for Chronicling America style linking
    attr_writer :publication_unique_id_property
    def publication_unique_id_property
      @publication_unique_id_property || :lccn
    end

    attr_writer :publication_unique_id_field
    def publication_unique_id_field
      @publication_unique_id_field || 'lccn_tesim'
    end
  end
end
