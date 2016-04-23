class Gain < ActiveRecord::Base

  enum category: [:administrative, :non_aministrative, :other]

  belongs_to :proclamation

end
