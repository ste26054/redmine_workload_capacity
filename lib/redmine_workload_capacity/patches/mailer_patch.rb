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
    		subject = "TRalalal Submitted by #{@user.name}"

        mail :to => recipients, :cc => cc, :subject => subject
       	#mail :to => [User.find(94)], :cc => cc, :subject => subject

    	end

    end
  end	
end