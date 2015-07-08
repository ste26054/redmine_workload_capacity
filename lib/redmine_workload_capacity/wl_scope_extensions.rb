module WlScopeExtension
	module Dates #Shared attributes: start_date, end_date
		def self.included(k)
			k.scope :overlaps, ->(fr, to) { k.where("(DATEDIFF(start_date, ?) * DATEDIFF(?, end_date)) >= 0", to, fr) }
		end
	end

	module Users
		def self.included(k)
			k.scope :for_user, ->(uid) { k.where(user_id: uid) }
		end
	end

end