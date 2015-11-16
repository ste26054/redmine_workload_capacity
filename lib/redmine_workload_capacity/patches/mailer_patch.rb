module RedmineWorkloadCapacity
  module Patches

    module MailerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end 
    end

    module InstanceMethods

    	def wl_notify(recipients, project, arg)
        redmine_headers 'Project-Id' => project.id,
                    'User' => arg[:user].login 


         message_id project
         references project
    		@project = project
        @user = arg[:user]
        @ratio = arg[:ratio]
        @recp = recipients.collect { |r| r.login }


    		cc = []
    		subject = "Allocation Check for #{@user.name}"

        mail :to => recipients, :cc => cc, :subject => subject
    	end

    end
  end	
end