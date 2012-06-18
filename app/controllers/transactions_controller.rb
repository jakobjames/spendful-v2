class TransactionsController < ApplicationController
  
  before_filter do
    @budget = find_budget
    @item = find_item
    @occurrence = find_occurrence
  end
  
  def new
    if @occurrence.present?
      @transaction = @occurrence.transactions.new
    else
      @transaction = @budget.transactions.new
    end
    @transaction.category = @occurrence.category
  end

  def create
    params[:transaction][:amount] = money_to_integer(params[:transaction][:amount])
    if @occurrence.present?
      @transaction = @occurrence.transactions.new(params[:transaction])
    else
      @transaction = @budget.transactions.new(params[:transaction])
    end
    @transaction.category = @occurrence.category

    if @transaction.save
		  flash[:notice] = "Transaction saved"
      redirect_to budget_path(@budget, :month => session[:budget_date].month, :year => session[:budget_date].year), :status => 201
    else
      render :new
    end
  end
  
  def edit
    @transaction = find_transaction
  end

  def update
    params[:transaction][:amount] = money_to_integer(params[:transaction][:amount])
    
    @transaction = find_transaction

    if @transaction.update_attributes(params[:transaction])
	    flash[:notice] = "Transaction updated"
      if @occurrence.present?
        redirect_to edit_budget_item_transaction_path(@budget, @item, @transaction, {:occurrence => @occurrence.date}), :status => 201
      else
        redirect_to edit_budget_transaction_path(@budget, @transaction), :status => 201
      end
    else
      render :edit
    end
  end

  def destroy
    @transaction = find_transaction
    @transaction.destroy
    flash[:notice] = "Transaction deleted"
    redirect_to budget_path(@budget, :month => session[:budget_date].month, :year => session[:budget_date].year)
  end

	protected

  def find_budget
    self.current_user.budgets.find_by_slug(params[:budget_id])
  end

  def find_item
    @budget.items.find_by_id(params[:item_id])
  end

  def find_occurrence
    @item.occurrences.fetch(params[:occurrence]) if params[:occurrence].present?
  end

  def find_transaction
    @budget.transactions.find_by_id(params[:id])
  end
end
