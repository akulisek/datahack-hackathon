class Functionary < ActiveRecord::Base

  has_many :proclamations
  has_many :internal_numbers
  has_many :gains, through: :proclamations
  has_many :reimbursements, through: :proclamations
  has_many :estates, through: :proclamations
  has_many :chattels, through: :proclamations
  has_many :jobs, through: :proclamations

  # FILTERRIFIC
  # define ActiveRecord scopes for
  # :search_query, :sorted_by, :with_country_id, and :with_created_at_gte
  filterrific(
      default_filter_params: { sorted_by: 'full_name_asc' },
      available_filters: [
          :sorted_by,
          :search_query
          #:with_created_at_gte
      ]
  )

  # self.per_page = 10

  scope :search_query, lambda { |query|
                       # Searches the users table on the 'first_name' and 'last_name' columns.
                       # Matches using LIKE, automatically appends '%' to each term.
                       # LIKE is case INsensitive with MySQL, however it is case
                       # sensitive with PostGreSQL. To make it work in both worlds,
                       # we downcase everything.
                       return nil  if query.blank?

                       query = I18n.transliterate(query)
                       puts "\n\n\n\n\n"+query+"\n\n\n"
                       # condition query, parse into individual keywords
                       terms = query.to_s.downcase.split(/\s+/)

                       # replace "*" with "%" for wildcard searches,
                       # append '%', remove duplicate '%'s
                       terms = terms.map { |e|
                         (e.gsub('*', '%') + '%').gsub(/%+/, '%')
                       }
                       # configure number of OR conditions for provision
                       # of interpolation arguments. Adjust this if you
                       # change the number of OR conditions.

                       #POSTGRESQL DEPENDENCY: UNACCENT EXTENSION!!! (create extension unaccent;)
                       num_or_conds = 3
                       where(
                           terms.map {
                             or_clauses = [
                                 "LOWER(UNACCENT(functionaries.first_name)) LIKE ?",
                                 "LOWER(UNACCENT(functionaries.last_name)) LIKE ?",
                                 "LOWER(UNACCENT(functionaries.full_name)) LIKE ?"
                             ].join(' OR ')
                             "(#{ or_clauses })"
                           }.join(' AND '),
                           *terms.map { |e| [e] * num_or_conds }.flatten
                       )
                     }

  scope :sorted_by, lambda { |sort_option|
                    # extract the sort direction from the param value.
                    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
                    case sort_option.to_s
                      when /^full_name_/
                        # Simple sort on the name colums
                        order("LOWER(functionaries.full_name) #{ direction }")
                      else
                        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
                    end
                  }

  scope :with_created_at_gte, lambda { |ref_date|
                              where('functionaries.created_at >= ?', ref_date)
                            }

  def self.options_for_sorted_by
    [
        ['Name (a-z)', 'full_name_asc'],
        ['Name (z-a)', 'full_name_desc']
    ]
  end

end
