class User
    module Authentication

        ##verification 
        def start_verification
            generate_code("verification")
            code = Rails.cache.read("verification_code_for_#{self.phone_number}")
            puts code

            #send sms
            body = "You are trying to sign up for CoinSwift using this phone number. Enter this code to confirm registration: #{code}"
            Twilio::SmsService.new(rec_phone_number: self.phone_number, body: body).send_msg
        end
  
        def check_verification(input_code)
            code = Rails.cache.read("verification_code_for_#{self.phone_number}")
            if code.nil?
                start_verification
                {message: {errors: ["Code has expired. New verification code have been sent to #{self.phone_number}"]}, status: :unprocessable_entity}
            elsif code == input_code.to_i
                self.verify!
                {message: {status: ['Account verified']}, status: :ok}
            else 
                {message: {errors: ['Incorrect code']}, status: :unprocessable_entity}
            end
        end

        ##password_reset

        def start_password_reset
            generate_code("reset")
            code = Rails.cache.read("reset_code_for_#{self.phone_number}")
            puts code
            #send sms
            body = "Enter this code along with your new password to confirm reset: #{code}"
            Twilio::SmsService.new(rec_phone_number: self.phone_number, body: body).send_msg
        end
    
        def confirm_password_reset(input_code, new_password)
            code = Rails.cache.read("reset_code_for_#{self.phone_number}")
            if code.nil?
                start_password_reset
                {message: {errors: ["Code has expired. New reset code have been sent to #{self.phone_number}"]}, status: :unprocessable_entity}
            elsif code == input_code.to_i
                self.update_password(new_password)
                {message: {status: ['Password has been reset']}, status: :accepted}
            else 
                {message: {errors: ['Incorrect code']}, status: :unprocessable_entity}
            end
        end
    

        private

        def generate_code(type)
            ver_code = rand(100000..999999)
            Rails.cache.write("#{type}_code_for_#{self.phone_number}", ver_code, expires_in: 5.minutes)
            ver_code
        end
    end
end
  