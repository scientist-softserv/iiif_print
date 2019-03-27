module NewspaperWorks
  class Configuration

    attr_writer :title_unique_id_field
    def title_unique_id_field
      @title_unique_id_field || 'lccn_sim'
    end

  end
end
