class Occurrences
  def initialize(item)
    @item = item
  end # def initialize

  def all
    # IceCube won't return all occurrences if there is no ending date
    raise 'Item must have an ending date to access all occurrences. Use #until or #limit instead.' unless @item.ends_on

    @item.ice_cube_schedule.all_occurrences.collect { |ice_cube_occurrence| Occurrence.new :item => @item, :date => ice_cube_occurrence.to_date }
  end # def all

  def limit(number)
    @item.ice_cube_schedule.first(number).collect { |ice_cube_occurrence| Occurrence.new :item => @item, :date => ice_cube_occurrence.to_date }
  end

  def until(ending)
    self.between(@item.starts_on, ending)
  end

  def between(starting, ending)
    if @item.ends_on && ending > @item.ends_on
      ending = @item.ends_on
    end
      
    starting = Occurrences.ensure_time starting
    ending = Occurrences.ensure_time ending
    
    @item.ice_cube_schedule.occurrences_between(starting, ending).collect { |ice_cube_occurrence| Occurrence.new :item => @item, :date => ice_cube_occurrence.to_date }
  end # def between

  def exists?(date)
    date = Occurrences.ensure_time date
    return false unless date

    exceptions = @item.ice_cube_schedule.exception_times.collect
    @item.ice_cube_schedule.occurs_on?(date) && !exceptions.include?(date)
  end

  def fetch(date)
    date = Occurrences.ensure_date date
    return nil unless date && self.exists?(date)
    Occurrence.new :item => @item, :date => date
  end

  def ordinal(position)
    return nil if position < 1

    ice_cube_occurrences = @item.ice_cube_schedule.first(position)
    return nil if position > ice_cube_occurrences.size

    Occurrence.new :item => @item, :date => ice_cube_occurrences.last.to_date
  end

  def first
    self.ordinal(1)
  end

  private

  def self.ensure_date(date_or_string)
    begin
      date_or_string = Date.parse(date_or_string) if date_or_string.is_a?(String)
      date_or_string
    rescue
      nil
    end
  end

  def self.ensure_time(date_or_string)
    begin
      date_or_string = Date.parse(date_or_string) if date_or_string.is_a?(String)
      date_or_string = date_or_string.to_time unless date_or_string.is_a?(Time)
      date_or_string
    rescue
      nil
    end
  end
end
