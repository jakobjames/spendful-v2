class Country < ActiveRecord::Base
  attr_accessible :code, :name, :currency
  
  has_many :users

  validates :code, :presence => true, :uniqueness => true
  validates :name, :presence => true, :uniqueness => true
end
