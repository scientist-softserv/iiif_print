# frozen_string_literal: true

namespace :hyku do
  namespace :update do
    desc 'Make sure all child work models have the correct attribute'
    task is_child_attribute: [:environment] do
      if defined? Account # is this a hyku app?
        Account.find_each do |account|
          switch!(account.cname)
          puts "********************** switched to #{account.cname} **********************"
          touch_records
        end
      else # this must be a hyrax app
        touch_records
      end
      puts "********************** DONE! **********************"
    end

    def touch_records
      Hyrax.config.curation_concerns.each do |cc|
        puts "********************** checking #{cc}s **********************"
        next if cc.count.zero?

        cc.find_each(&:save)
      end
    rescue StandardError => e
      puts "********************** #{e} **********************"
    end
  end
end
