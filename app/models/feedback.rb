class Feedback < ActiveRecord::Base
  
  attr_accessible :message
  
  belongs_to :user
  
  validates_presence_of :message
  
end
