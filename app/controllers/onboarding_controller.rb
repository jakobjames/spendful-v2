class OnboardingController < ApplicationController
  
  def new
  end

	def step1
		@old_budget = current_user.budgets.find_by_slug("personal")
		redirect_to budget_path(@old_budget, :params => {:tour => true}) and return if @old_budget
    @budget = current_user.budgets.create({:name => "Personal", :initial_balance => 0})
    @item = @budget.items.new
    @item.starts_on = Date.today
    @item.amount = 100000
	end
  
  def step2
    @budget = current_user.budgets.find(params[:budget_id])
    
    params[:item][:amount] = money_to_integer(params[:item][:amount])
    @budget.items.create(params[:item])
    @item = @budget.items.new
    @item.starts_on = Date.today
    @item.amount = 10000
  end
  
  def finish
    @budget = current_user.budgets.find(params[:budget_id])
    
    params[:item][:amount] = money_to_integer(params[:item][:amount])
    @budget.items.create(params[:item])
    
    redirect_to budget_path(@budget, :params => {:tour => true})
  end

end
