require 'spotlight'

module Spotlight::Concerns
  # Inherit from the host app's ApplicationController
  # This will configure e.g. the layout used by the host
  module ApplicationController
    extend ActiveSupport::Concern
    include Spotlight::Controller
    
    included do
      layout 'spotlight/spotlight'
      
      helper Spotlight::ApplicationHelper

      rescue_from CanCan::AccessDenied do |exception|
        redirect_to main_app.root_url, :alert => exception.message
      end
    end
  end
end
