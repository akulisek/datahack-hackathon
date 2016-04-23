class Reimbursement < ActiveRecord::Base

  enum category: [:administrative, :other]

  belongs_to :proclamation

end
