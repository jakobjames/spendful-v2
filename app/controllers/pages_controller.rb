class PagesController < ApplicationController
	skip_before_filter :authenticate_user, :check_subscription
end
