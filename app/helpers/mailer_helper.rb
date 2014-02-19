module MailerHelper

  def host
    case Rails.env
      when "production" then "www.spendful.com"
      when "development" then "localhost:3000"
      else "spendful.com"
    end
  end

  def url
    "http://" + host
  end

end
