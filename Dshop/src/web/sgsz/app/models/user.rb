require 'digest/sha2'

class User < ActiveRecord::Base
	attr_accessible :address, :age, :cdate, :loginname, :position, :remark, :salari, :sex, :stid, :stname, :tel, :uid, :uname, :userpass, :password, :password_confirmation

	validates :password, :confirmation => true

	attr_accessor :password_confirmation
	attr_reader :password
	validate :password_must_be_present

	class << self
		def authenticate(name, password)
			if user = find_by_uname(name)
				if user.hashed_password == encrypt_password(password, user.salt)
					user
				end
			end
		end
		def encrypt_password(password, salt)
			Digest::SHA2.hexdigest(password + "wibble" + salt)
		end
	end
	
	# 'password' is a virtual attribute
	def password=(password)
		@password = password
		if password.present?
			generate_salt
			self.hashed_password = self.class.encrypt_password(password, salt)
		end
	end

	private
	def password_must_be_present
		errors.add(:password, "Missing password") unless hashed_password.present?
	end
	
	def generate_salt
		self.salt = self.object_id.to_s + rand.to_s
	end

end
