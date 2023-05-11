module Twilio
  class SmsService

    TWILIO_ACCOUNT_SID = 'AC801760b0c70f38a62e2908dc4dbb9f6a'
    TWILIO_AUTH_TOKEN = 'b436c4b671abcc2057c44213321660d8'
    TWILIO_FROM_PHONE = '+15855412637'
    TWILIO_TEST_PHONE = '+639456421993'

    def initialize(rec_phone_number:, body:)
      @body = body
      @rec_phone_number = rec_phone_number
    end

    def send_msg
      @client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
      message = @client.messages
        .create(
          body: @body,
          from: TWILIO_FROM_PHONE,
          to: @rec_phone_number
        )
      puts message.sid
    end

    def add_caller_id
      @client = Twilio::REST::Client.new(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
      @client.validation_requests.create(
         friendly_name: 'mama',
         phone_number: '+639159622308'
       )
       puts validation_request.friendly_name
    end




  end
end
