class StopMailer < ActionMailer::Base
  default from: "sentinel@mattforni.com"
  helper :application

  STOPPED_OUT_SUBJECT = 'Some of your positions have stopped out!'

  def stopped_out(email, stops)
    @stops = stops
    mail(to: email, subject: STOPPED_OUT_SUBJECT)
  end
end

