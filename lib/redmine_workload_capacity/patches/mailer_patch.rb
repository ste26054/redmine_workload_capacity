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
        @recp = recipients.collect { |r| r.login }


    		cc = []
    		subject = "blabla Submitted by #{@user.name}"

        # mail :to => [User.find(87), User.find(91)], :cc => cc, :subject => subject
       	mail :to => [User.find(159), User.find(87)], :cc => cc, :subject => subject
    	end

    end
  end	
end