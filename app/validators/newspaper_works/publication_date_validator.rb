module NewspaperWorks
  # validates that a properly formatted date has been entered
  class PublicationDateValidator < ActiveModel::Validator
    DATE_REGEX = /\A\d{4}-((0[1-9])|(1[0-2]))-((0[1-9])|([1-2][0-9])|(3[0-1]))\z/
    def validate(record)
      error_msg = "Incorrect Date. Date input should be formatted yyyy-mm-dd and be a valid date."
      return unless record.publication_date.present?
      unless DATE_REGEX.match(record.publication_date)
        record.errors[:publication_date] << error_msg
        return
      end
      date_split = record.publication_date.split("-").map(&:to_i)
      record.errors[:publication_date] << error_msg unless Date.valid_date?(date_split[0], date_split[1], date_split[2])
    end
  end
end
