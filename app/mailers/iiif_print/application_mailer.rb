# Application Mailer
module IiifPrint
  # Application Mailer Class
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end
