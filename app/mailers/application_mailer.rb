class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  def default_url_options
    { host: "www.markaligbe.com" }
  end
end
