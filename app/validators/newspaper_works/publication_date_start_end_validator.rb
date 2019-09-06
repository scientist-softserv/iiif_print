module NewspaperWorks
  # validates start and end date are properly formatted and end date comes after
  # or on the same date as the start date.
  class PublicationDateStartEndValidator < ActiveModel::Validator
    DATE_RANGE_REGEX = /\A\d{4}(-((0[1-9])|(1[0-2])))?(-(([0-2][1-9])|3[0-1]))?\z/

    def validate(record)
      start_date = record.publication_date_start
      end_date = record.publication_date_end
      valid_dates?(start_date, end_date, record) && start_before_end?(start_date, end_date, record)
    end

    private

      def publication_date_valid?(pub_date)
        return false unless DATE_RANGE_REGEX.match(pub_date)
        date_split = pub_date.split("-").map(&:to_i)
        return false if date_split.length == 3 &&
                        !Date.valid_date?(date_split[0], date_split[1], date_split[2])
        true
      end

      def start_before_end?(start_date, end_date, record)
        return true unless start_date && end_date
        date_error = "Publication start date must be earlier or the same as end date."
        pub_start = start_date.split("-")
        pub_end = end_date.split("-")
        (0..2).each do |i|
          if pub_start[i] && pub_end[i] && pub_end[i] < pub_start[i]
            record.errors[:publication_date_start] << date_error
            break
          end
        end
        record.errors[:publication_date_start].blank?
      end

      def valid_dates?(start_date, end_date, record)
        date_error = "Incorrect Date. Date input should be formatted yyyy[-mm][-dd] and be a valid date."
        if start_date
          record.errors[:publication_date_start] << date_error unless publication_date_valid?(start_date)
        end
        if end_date
          record.errors[:publication_date_end] << date_error unless publication_date_valid?(end_date)
        end
        record.errors[:publication_date_start].blank? && record.errors[:publication_date_end].blank?
      end
  end
end
