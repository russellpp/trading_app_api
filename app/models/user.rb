class User < ApplicationRecord
	include User::Authentication

	has_secure_password

	has_many :user_roles, dependent: :destroy
	has_many :roles, through: :user_roles
	has_many :cryptos, through: :user_cryptos
	has_many :transactions
	
	validates :email, presence: true, uniqueness: {case_sensitive: true} 

	PHONE_REGEX = /\A\+639\d{9}\z/i
	validates :phone_number, presence: true, uniqueness: true, format: { with: PHONE_REGEX, message: "is in invalid number." }
	
	##verification methods

	def verify!
		self.verified = true
		self.save
		#send_sms("verification")
	end
	
	def approve!
        self.approved = true
        self.save
		#send_sms("approval")
		
    end
	
	def update_password(new_password)
        new_password_digest = BCrypt::Password.create(new_password)
        self.password_digest = new_password_digest
        self.save
		#send_sms("password_reset")
		
    end

	##balance updates

	def deposit(amount)
		if self.balance.nil?
			self.balance = 0
		  end
		  
		  new_balance = self.balance + amount
		  transaction = FundsTransfer.create(transaction_type: 'deposit', amount: amount, user: self)
		  
		  if self.update(balance: new_balance)
			{ message: { messages: ["An amount of #{amount} has been deposited to your account"] }, status: :accepted }
		  else
			{ message: { errors: ['Failed to update the balance'] }, status: :unprocessable_entity }
		  end
	end
	
	def withdraw(amount)
		if self.balance && self.balance >= amount
			new_balance = self.balance -= amount
			transaction = FundsTransfer.create(transaction_type: 'withdraw', amount: amount, user: self)
			if self.update(balance: new_balance)
				{message: { messages: ["An amount of #{amount} has been withdrawed to your account. Balance: #{self.balance}"] }, status: :accepted}
			else
				{ message: { errors: ['Failed to update the balance'] }, status: :unprocessable_entity }
			end
		else
		  	{message: { errors: ['Insufficient balance'] }, status: :unprocessable_entity}
		end
	end
	
	# private

	# def send_sms(type)
	# 	if type === "verification"
	# 		body = "Your account has been verified. You may now login and use CoinSwift."
	# 	elsif type === "approval"
	# 		body = "Your account has been approved for trading. You may now buy and sell stocks in CoinSwift."
	# 	elsif type === "password_reset"
	# 		body = "Password reset for Coinswift successful."
	# 	end

	# 	Twilio::SmsService.new(rec_phone_number: self.phone_number, body: body).send_msg
	# end

end
