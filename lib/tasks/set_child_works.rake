# frozen_string_literal: true

namespace :iiif_print do
  namespace :update do
    desc 'Make sure all child work models have the correct attribute'
    task is_child_attribute: [:environment] do
      Account.find_each do |account|
        begin
          switch!(account.cname) if defined? Account
          puts "********************** switched to #{account.cname} **********************"
          Hyrax.config.curation_concerns.each do |cc|
            puts "********************** checking #{cc}s **********************"
            next if cc.count.zero?

            cc.find_each(&:save)
          end
        rescue StandardError
          puts "********************** failed to update account #{account.cname} **********************"
          next
        end
      end
    end
  end
end
