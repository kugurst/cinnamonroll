class ApplicationMailer < ActionMailer::Base
  default from: "i.am+noreply@markaligbe.com"
  layout 'mailer'

  def default_url_options
    { host: "markaligbe.com" }
  end
end
