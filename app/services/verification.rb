require 'bcrypt'

class Verification

    def initialize (rec_phone_number:)
        @rec_phone_number = rec_phone_number
    end

    ##put in private method

    def generate_code
        ver_code = rand(100000..999999)
        Rails.cache.write("verification_code_for_#{@rec_phone_number}", ver_code, expires_in: 5.minutes)
        ver_code
    end

    def generate_reset_code
        ver_code = rand(100000..999999)
        Rails.cache.write("password_reset_code_for_#{@rec_phone_number}", ver_code, expires_in: 5.minutes)
        ver_code
    end


    #verification code 
        ##put in a module User::Verification under models
        
    def start_verification
        generate_code
        code = Rails.cache.read("verification_code_for_#{@rec_phone_number}")
        
        #send sms
        body = "You are trying to sign up for CoinSwift using this phone number. Enter this code to confirm registration: #{code}"
        send_sms(body)
    end

    def check_verification(input_code)
        code = Rails.cache.read("verification_code_for_#{@rec_phone_number}")
        if code.nil?
            start_verification
            {message: {errors: ["Code has expired. New verification code have been sent to #{@rec_phone_number}"]}, status: :unprocessable_entity}
        elsif code == input_code
            update_verification
            {message: {status: ['Account verified']}, status: :accepted}
        else 
            {message: {errors: ['Incorrect code']}, status: :unprocessable_entity}
        end
        
    end

    #password reset
    
    def start_reset
        generate_reset_code
        code = Rails.cache.read("password_reset_code_for_#{@rec_phone_number}")

        #send sms
        body = "Enter this code along with your new password to confirm reset: #{code}"
        send_sms(body)
    end

    def confirm_reset(input_code, new_password)
        code = Rails.cache.read("password_reset_code_for_#{@rec_phone_number}")
        if code.nil?
            start_reset
            {message: {errors: ["Code has expired. New reset code have been sent to #{@rec_phone_number}"]}, status: :unprocessable_entity}
        elsif code == input_code
            update_password(new_password)
            {message: {status: ['Password has been reset']}, status: :accepted}
        else 
            {message: {errors: ['Incorrect code']}, status: :unprocessable_entity}
        end
    end

    # update actions

    def update_verification
        user = User.find_by(phone_number: @rec_phone_number)
        user.verified = true
        user.save

        #send account is verified
        body = "Your account registered under this number has been verified. You may now login and use CoinSwift."
        send_sms(body)
    end

    def update_approval
        user = User.find_by(phone_number: @rec_phone_number)
        user.approved = true
        user.save

        #send account is approved
        body = "Your account registered under this number has been approved for trading. You may now buy and sell stocks in CoinSwift."
        send_sms(body)
    end

    def update_password(new_password)
        user = User.find_by(phone_number: @rec_phone_number)
        new_password_digest = BCrypt::Password.create(new_password)
        user.password_digest = new_password_digest
        user.save

        #send account is approved
        body = "Password reset for Coinswift successful."
        send_sms(body)
    end

    #twilio service
        #call this as one line in methods that call it

    def send_sms(body)
        new_msg = Twilio::SmsService.new(rec_phone_number: @rec_phone_number, body: body)
        new_msg.send_msg
    end

    

end