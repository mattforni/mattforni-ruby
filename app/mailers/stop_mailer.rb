class StopMailer < ActionMailer::Base
  default from: "sentinel@example.com"

  STOPPED_OUT_SUBJECT = 'Some of your positions have stopped out'

  def stopped_out(stops)
    @stops = stops
    mail(to: 'mattforni@gmail.com', subject: STOPPED_OUT_SUBJECT)
  end
end
