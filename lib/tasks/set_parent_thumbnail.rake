# frozen_string_literal: true

namespace :iiif_print do
  namespace :update do
    desc 'Make sure all works have a thumbnail'
    task set_parent_thumbnail: [:environment] do
      Account.find_each do |account|
        begin
          switch!(account.cname) if defined? Account
          puts "********************** switched to #{account.cname} **********************"
          Hyrax.config.curation_concerns.each do |cc|
            next if cc.count.zero?

            puts "********************** checking #{cc}s **********************"
            cc.find_each do |work|
              # the representative thumbnail for the parent should be the first page sorted alphanumerically by source_identifier
              sorted_children = work.child_works&.sort_by { |child_work| child_work.identifier.first }
              child_work = sorted_children.first
              next if work.thumbnail || child_work.blank?

              work.representative = child_work.file_sets.first if work.representative_id.blank?
              work.thumbnail = child_work.file_sets.first if work.thumbnail_id.blank?
              pdf = child_work.file_sets.select { |f| f.label.match(/.pdf/) }.first
              byebug
              work.update_attributes!(rendering_ids: [pdf.id]) if pdf.present?
              work.save
            end
            puts "********************** updated #{cc}s **********************"
          end
        rescue StandardError => e
          puts "********************** error: #{e} **********************"
          next
        end
      end
    end
  end
end
