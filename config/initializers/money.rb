no_currency = {
  :priority        => 100,
  :iso_code        => "NONE",
  :iso_numeric     => "",
  :name            => "None",
  :symbol          => "",
  :subunit         => "",
  :html_entity     => "",
  :subunit_to_unit => 100,
  :separator       => ".",
  :delimiter       => ","
}

Money::Currency.register(no_currency)

Money.default_currency = Money::Currency.new("NONE")
