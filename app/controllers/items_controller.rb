class ItemsController < ApplicationController
  
  before_filter do
    @budget = find_budget
  end
  
  def new
    @item = @budget.items.new
    @item.category = params[:category]
  end

  def create
    params[:item][:amount] = money_to_integer(params[:item][:amount])
    @item = @budget.items.new(params[:item])

    if @item.save
		  flash[:notice] = "Item saved"
      redirect_to budget_path(@budget, :month => session[:budget_date].month, :year => session[:budget_date].year), :status => 201
    else
      render :new
    end
  end
  
  def edit
    @item = find_item
    @occurrence = @item.occurrences.fetch(params[:occurrence])
    redirect_to(not_found_path) unless @occurrence
  end

  def update
    params[:item][:amount] = money_to_integer(params[:item][:amount]) if params[:item][:amount]
    
    @item = find_item
    @occurrence = @item.occurrences.fetch(params[:occurrence])
    redirect_to(not_found_path) and return unless @occurrence

    if @occurrence.update_attributes(params[:item])
	    flash[:notice] = "Item updated"
      redirect_to budget_path(@budget, :month => session[:budget_date].month, :year => session[:budget_date].year), :status => 201
    else
      render :edit
    end
  end

  def destroy
    @item = find_item
    @occurrence = @item.occurrences.fetch(params[:occurrence])
    if @occurrence.present?
      @occurrence.destroy
      flash[:notice] = "Item occurrence deleted"
    else
      @item.destroy
      flash[:notice] = "Item deleted"
    end
    redirect_to budget_path(@budget, :month => session[:budget_date].month, :year => session[:budget_date].year)
  end

	protected

  def find_budget
    if params[:budget_id]
      self.current_user.budgets.find_by_slug(params[:budget_id])
    else
      self.current_user.budgets.find_by_slug(params[:id])
    end
  end

  def find_item
    @budget.items.find_by_id(params[:id]) || @budget.items.find_by_id(params[:item_id])
  end
end
