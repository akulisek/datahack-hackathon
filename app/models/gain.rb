class Gain < ActiveRecord::Base

  enum category: [:administrative, :non_aministrative, :other]

  belongs_to :proclamation

  def convert_value_to_eur
    currency.include?("€") ? value : (value * 3.126).round
  end

end
