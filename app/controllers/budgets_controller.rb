class BudgetsController < ApplicationController
  
  def index
    redirect_to next_available_budget_path
    # @budgets = current_user.budgets
  end

  def show
    @budget = find_budget
    redirect_to(not_found_path) unless @budget
    @today = Date.today
    @date = @today
    if params[:month] && params[:year]
			@date = @date.beginning_of_month
      @date = @date.change(:month => params[:month].to_i, :year => params[:year].to_i)
    end
    session[:budget_date] = @date
    @date_beginning = @date.beginning_of_month
    @date_end = @date.end_of_month
  end

  def new
    @budget = Budget.new
    @budget.name = "Personal"
  end

  def create
    params[:budget][:initial_balance] = money_to_integer(params[:budget][:initial_balance])
    # Don't use the form self.current_user.budgets.new(params[:budget]) here because when
    # it fails, the unsaved budget will already be in the current_user.budgets association
    # and will cause grief in the _header and _footer templates.
    @budget = Budget.new(params[:budget])
    @budget.user_id = self.current_user.id

    if @budget.save
		  flash[:notice] = Constants::Budgets::CREATED_MESSAGE
      redirect_to budget_path(@budget)
    else
      render :new
    end
  end

  def edit
    @budget = find_budget
    redirect_to(not_found_path) unless @budget
  end

  def update
    @budget = find_budget
    redirect_to(not_found_path) and return unless @budget
    
    params[:budget][:initial_balance] = money_to_integer(params[:budget][:initial_balance])

    if @budget.update_attributes(params[:budget])
	    flash[:notice] = Constants::Budgets::UPDATED_MESSAGE
      redirect_to edit_budget_path(@budget)
    else
      render :edit
    end
  end

  def destroy
    @budget = find_budget
    @budget.destroy
    flash[:notice] = "Budget deleted"
    redirect_to next_available_budget_path
  end

	protected

  def find_budget
    self.current_user.budgets.find_by_slug(params[:id]) || self.current_user.budgets.find_by_slug(params[:budget_id])
  end
  
  def next_available_budget_path
    self.current_user.budgets.any? ? budget_path(self.current_user.budgets.order(:updated_at).first) : new_budget_path
  end
end
