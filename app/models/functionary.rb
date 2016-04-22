class Functionary < ActiveRecord::Base

  has_many :proclamations
  has_many :internal_numbers
  has_many :gains, through: :proclamations
  has_many :reimbursements, through: :proclamations
  has_many :estates, through: :proclamations
  has_many :chattels, through: :proclamations
  has_many :jobs, through: :proclamations

end
