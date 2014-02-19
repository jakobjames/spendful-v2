# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => "Chicago' }, { :name => "Copenhagen' }])
#   Mayor.create(:name => "Emanuel", :city => cities.first)

@user = User.create({:email => "mitchell@spendful.com", :password => "password"})

@date = (Date.today - 2.months)

@budget = @user.budgets.create({:name => "Personal", :initial_balance => "10000", :currency => "GBP", :created_at => @date})

@item = @budget.items.create({:category => "income", :name => "Salary", :amount => "100000", :starts_on => @date.change(:day => 20), :schedule => "monthly"})
@item = @budget.items.create({:category => "income", :name => "Savings", :amount => "5000", :starts_on => @date.change(:day => 6), :schedule => "monthly"})
@item = @budget.items.create({:category => "income", :name => "Shared Expenses", :amount => "3000", :starts_on => @date.change(:day => 3), :schedule => "weekly"})

@item = @budget.items.create({:category => "expense", :name => "House Rent", :amount => "60000", :starts_on => @date.change(:day => 5), :schedule => "monthly"})
@item = @budget.items.create({:category => "expense", :name => "Groceries", :amount => "5000", :starts_on => @date.change(:day => 1), :schedule => "weekly"})
@item = @budget.items.create({:category => "expense", :name => "House Bills", :amount => "1500", :starts_on => @date.change(:day => 3), :schedule => "weekly"})
@item = @budget.items.create({:category => "expense", :name => "Car", :amount => "30000", :starts_on => @date.change(:day => 20), :schedule => "monthly"})
@item = @budget.items.create({:category => "expense", :name => "John's Birthday", :amount => "10000", :starts_on => @date.change(:day => 27), :schedule => "once"})
