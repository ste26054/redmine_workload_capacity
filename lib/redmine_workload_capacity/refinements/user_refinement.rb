module RedmineWorkloadCapacity
	module Refinements
		module UserRefinement
			refine User do
				def allowed_to?(action, context, options={}, &block)
				    if context && context.is_a?(Project)
				      return false unless context.allows_to?(action)

				      #return true if admin? #CHANGED HERE

				      roles = roles_for_project(context)
				      return false unless roles
				      roles.any? {|role|
				        (context.is_public? || role.member?) &&
				        role.allowed_to?(action) &&
				        (block_given? ? yield(role, self) : true)
				      }
				    elsif context && context.is_a?(Array)
				      if context.empty?
				        false
				      else
				        # Authorize if user is authorized on every element of the array
				        context.map {|project| allowed_to?(action, project, options, &block)}.reduce(:&)
				      end
				    elsif context
				      raise ArgumentError.new("#allowed_to? context argument must be a Project, an Array of projects or nil")
				    elsif options[:global]
				      # Admin users are always authorized
				      #return true if admin? #CHANGED HERE

				      # authorize if user has at least one role that has this permission
				      roles = memberships.collect {|m| m.roles}.flatten.uniq
				      roles << (self.logged? ? Role.non_member : Role.anonymous)
				      roles.any? {|role|
				        role.allowed_to?(action) &&
				        (block_given? ? yield(role, self) : true)
				      }
				    else
				      false
				    end
				end
			end
		end
	end
end