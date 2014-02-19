module BudgetsHelper
	def budget?
		@budget && !@budget.new_record? && params[:action] == 'show'
	end

	def budgets?
	  if current_user
	    self.current_user.budgets.any?
	  end
	end
end
