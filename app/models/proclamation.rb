class Proclamation < ActiveRecord::Base

  belongs_to :functionary
  has_many :gains
  has_many :reimbursements
  has_many :estates
  has_many :chattels
  has_many :jobs

end
