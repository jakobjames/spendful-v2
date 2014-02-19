module Constants
  module Budgets
    CREATED_MESSAGE = 'This is your new budget.'
    UPDATED_MESSAGE = 'Your budget was successfully updated.'
  end

  module Items
    CATEGORIES = %w(income expense)
    SCHEDULES = %w(once weekly fortnightly monthly yearly)
  end

  module Transactions
    NO_DESCRIPTION = 'No description given.'
  end

  module Users
    PLEASE_LOG_IN = 'Please log in.'
    UNKNOWN_EMAIL = "That email address isn't registered."
    WRONG_PASSWORD = 'Password is incorrect.'
    LOGIN_SUCCESSFUL = "You're in!"
    LOGOUT_SUCCESSFUL = 'You have been logged out.'
    WELCOME_MESSAGE = 'Your details have been saved. Welcome to Spendful!'
    DETAILS_UPDATED = 'Your details were successfully updated.'
    ACCOUNT_DELETED = 'Your account has been successfully deleted.'
  end

  module Subscriptions
    ALREADY_CURRENT_SUBSCRIPTION_ERROR = 'There is already a current subscription'

    STATUS_ACTIVE = 'Active'
    STATUS_EXPIRED = 'Expired'
    STATUS_CANCELLED = 'Cancelled'
    STATUS_IN_GRACE_PERIOD = 'In Grace Period'

    GRACE_PERIOD = 7
    TRIAL_PERIOD = 60
    
    LAUNCH_DATE = Date.parse("15th December 2013")

    PLANS = [
      {:id => "premium-monthly-v1", :name => "Premium Monthly", :amount => "1", :interval => 1.month},
      {:id => "premium-yearly-v1", :name => "Premium Yearly", :amount => "10", :interval => 1.year}
    ]
  end # module Subscriptions
  
  module Formats
    SHORT_DATE = "%a %e %b"
  end
end # module Constants