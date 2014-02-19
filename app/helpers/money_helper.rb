module MoneyHelper
  
  def money_to_integer(value)
    value.to_money.cents
  end
  
  def cents_to_money(integer, currency="NONE")
    if currency.nil? || !major_currencies.map{ |c| c.to_s }.include?(currency)
      currency = "NONE"
    end
    Money.new((integer || 0), currency)
  end

  def major_currencies
    hash = Money::Currency.table
    currencies = []
    hash.keys.each do |key|
      if hash[key][:priority] && hash[key][:priority] < 15
        currencies.push(key.upcase)
      end
    end
    currencies
  end

  def major_currencies_with_symbol
    hash = Money::Currency.table
    currencies = {}
    currencies["No Currency / Other"] = "NONE"
    hash.keys.each do |key|
      if hash[key][:priority] && hash[key][:priority] < 15
        currencies["#{key.upcase} &mdash; #{hash[key][:html_entity]}".html_safe] = key.upcase
      end
    end
    currencies
  end
  
end
