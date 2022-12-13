# frozen_string_literal: true

namespace :hyku do
  namespace :update do
    desc 'Make sure all child work models have the correct attribute'
    task is_child_attribute: [:environment] do
      Account.find_each do |account|
        switch!(account.cname)
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
