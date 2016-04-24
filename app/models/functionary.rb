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

  #self.per_page = 20
  paginates_per 50

  scope :search_query, lambda { |query|
                       # Searches the users table on the 'first_name' and 'last_name' columns.
                       # Matches using LIKE, automatically appends '%' to each term.
                       # LIKE is case INsensitive with MySQL, however it is case
                       # sensitive with PostGreSQL. To make it work in both worlds,
                       # we downcase everything.
                       return nil  if query.blank?

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

  STRUCTURE = ['Interné číslo', 'ID oznámenia', 'meno', 'oznámenie za rok',
               'oznámenie bolo podané', 'vykonávané funkcie', 'príjmy za rok',
               'paušálne náhrady za rok", "ostatné príjmy za rok',
               'spĺňa podmienky nezlučiteľnosti výkonu funkcie verejného funkcionára s výkonom iných funkcií, zamestnaní alebo činností podľa čl. 5 ods. 1 a 2 u. z. 357/2004',
               'vykonáva nasledovné zamestnanie v pracovnom pomere alebo obdobnom pracovnom vzťahu alebo štátnozamestnaneckom vzťahu (čl. 7 ods. 1 písm. b) u. z. 357/2004)',
               'vykonáva nasledovnú podnikateľskú činnosť (čl. 5 ods. 2 až 5 a čl. 7 ods. 1 písm. b) u. z. 357/2004)',
               'počas výkonu verejnej funkcie má tieto funkcie (čl. 7 ods. 1 písm. c) u. z. 357/2004)',
               'nehnuteľný majetok',
               'hnuteľný majetok, majetkové právo alebo iná majetková hodnota, existujúce záväzky, ktorých menovitá hodnota, bežná cena alebo peňažné plnenie presahuje 35-násobok minimálnej mzdy']

  def self.options_for_sorted_by
    [
        ['Name (a-z)', 'full_name_asc'],
        ['Name (z-a)', 'full_name_desc']
    ]
  end

  def self.get_all_functionaries
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'

    begin
      page = Nokogiri::HTML(open("http://www.nrsr.sk/web/Default.aspx?sid=vnf/zoznam&ViewType=1"))
    rescue OpenURI::HTTPError
      puts "404"
    end

    div_form_text = page.at_xpath('//div[@class="form"]').text

    div_form = page.css('div.form a').map { |link| link['href']}
    div_form.select { |link| !link.nil? && link.include?("Default") }

    div_form.each do |n|
      if n.nil?
        puts "nil"
      else
        parse_url("http://www.nrsr.sk/web/" + n)
      end
    end
  end

  def self.parse_url(url)
    require 'rubygems'
    require 'nokogiri'
    require 'open-uri'

    url = URI.escape(url)
    if (url.nil?)
      puts "nil"
    else
      begin
        page = Nokogiri::HTML(open(url))
      rescue OpenURI::HTTPError
        puts "404"
      else
        last_column = ""
        html_text_array = []
        if !page.nil? && !page.css("#_sectionLayoutContainer_ctl01_OutPut").nil? && !page.css("#_sectionLayoutContainer_ctl01_OutPut").css("table")[0].nil?
          page.css("#_sectionLayoutContainer_ctl01_OutPut").css("table")[0].css("tr").each do |tr|
            text = tr.css("td").text
            html_text_array << text
          end
          parse_html_text_rows(html_text_array)
        end
      end
    end
  end

  def self.parse_html_text_rows(html_text)
    functionary = nil
    internal_number = nil
    proclation = nil
    job = nil
    gain = nil

    index = 0
    text = html_text
    while index < text.length do
      f = text[index]
      if f.include?("Interné číslo") then
        internal_number = InternalNumber.where(value: text[index+1]).first_or_create
        index = index + 1
      elsif f.include?("ID oznámenia") then
        proclamation = Proclamation.where(global_id: text[index+1]).first_or_create
        index = index + 1
      elsif f.include?("meno:") then
        name = text[index+1].split(" ").select { |n| !n.include? '.'}
        functionary = Functionary.where(first_name: name[1], last_name: name[2], full_name: text[index+1]).first_or_create
        proclamation.update_attributes(functionary_id: functionary.id)
        index = index + 1
      elsif f.include?("rodné priezvisko") then
        if functionary
          functionary.update_attributes(surname_at_birth: text[index+1])
        end
        index = index + 1
      elsif f.include?("oznámenie za rok") then
        if proclamation
          proclamation.update_attributes(year: text[index+1])
        end
        index = index + 1
      elsif f.include?("oznámenie bolo podané") then
        if proclamation
          proclamation.update_attributes(adhibited_at: text[index+1])
        end
        index = index + 1
      elsif f.include?("vykonávané funkcie") then
        if proclamation
          proclamation.update_attributes(administrative_functions: text[index+1])
        end
        index = index + 1
      elsif f.include?("príjmy za rok") then
        gains = text[index+1].split('(')
        puts "GAINS: #{gains}"
        gains.each_with_index {|g, i|
          if i == 0
            if gains.size >= 2
              gain = Gain.where(category: 0, value: gains[0], currency: gains[1], proclamation_id: proclamation.id).first_or_create
              if gain
                gain.update_attributes(category: 0, value: gains[0], currency: gains[1], proclamation_id: proclamation.id)
              end
            end
          elsif i == 1
            g = g.split(')')
            if g[1] && !g[1].split(' ').nil? && g[1].split(' ').size >= 2
              gain = Gain.where(category: 1, value: g[1].split(' ')[0], currency: g[1].split(' ')[1], proclamation_id: proclamation.id).first_or_create
            end
          end
        }
        index = index + 1
      elsif f.include?("paušálne náhrady za rok") then
        reinbursements = text[index+1].split(' ')
        reinbursements.each_with_index {|g, i|
          if g.include?("z výkonu verejnej funkcie")
            reinbursement = Reimbursement.where(category: 0, value: gains[i-2], currency: gains[i-1], proclamation_id: proclamation.id).first_or_create
          elsif g.include?("iné")
            reimbursement = Reimbursement.where(category: 1, value: gains[i-2], currency: gains[i-1], proclamation_id: proclamation.id).first_or_create
          end
        }
        index = index + 1
      elsif f.include? "ostatné príjmy za rok" then
        puts f #gain = Gain.first_or_create(category: 2, value: gains[i-2], currency: gain[i-1], functionary_id: functionary.id, proclamation_id: proclamation.id)
      elsif f.include? "spĺňa podmienky nezlučiteľnosti výkonu funkcie verejného funkcionára s výkonom iných funkcií, zamestnaní alebo činností" then
        if text[index+1].include? "áno" then
          proclamation.update_attributes(satisfies_weird_conditions: true)
        elsif text[index+1].include? "nie" then
          proclamation.update_attributes(satisfies_weird_conditions: false)
        end
        index = index + 1
      elsif f.include? "vykonáva nasledovné zamestnanie v pracovnom pomere alebo obdobnom pracovnom vzťahu alebo štátnozamestnaneckom vzťahu" then
        if proclamation
          job = Job.where(proclamation_id: proclamation.id, description: text[index+1]).first_or_create
        end
        index = index + 1
      elsif f.include? "Dlhodobo plne uvoľnený na výkon verejnej funkcie podľa Zákonníka práce" then
        if f.split(':').include? "nie" then
          proclamation.update_attributes(released_in_long_term: false)
        elsif f.split(':').include? "áno" then
          proclamation.update_attributes(satisfies_weird_conditions: true)
        end
      elsif f.include? "vykonáva nasledovnú podnikateľskú činnosť" then
        if text[index+1].split(':').include? "nevykonávam" then
          proclamation.update_attributes(entepreneur_activity: "nevykonava")
        else
          proclamation.update_attributes(entepreneur_activity: text[index+1].split(':'))
        end
        index = index + 1
      elsif f.include? "počas výkonu verejnej funkcie má tieto funkcie" then
        #TODO maybe administrative function
      elsif f.include? "požitky:" then
        #TODO what is it?
      elsif f.include? "nehnuteľný majetok:" then

        while !text[index].include? "nehnuteľný majetok" do
          index = index + 1

          estate_text = text[index].split(';')
          estate = Estate.create()

          estate_text.each_with_index { |e, i|
            if e.include?("kat. územie") then
              estate.catastral_area = e.split(' ').select{|t| !t.include?("kat.") || !t.include?("územie")}
            elsif e.include?("číslo parcely") then
              estate.parcel_id = e.split(':')[1]
            elsif e.include?("LV č.") then
              estate.LV_id = e.split(' ').select{|t| !t.include?("LV") || !t.include?("č.")}
            elsif e.include?("podiel") then
              estate.interest = e.split(' ')[2]
            end
          }
          estate.proclamation_id = proclamation.id
          estate.save
        end
      elsif f.include? "hnuteľný majetok" do
        if !text[index+1].split(':').include? "nemám" then
          index = index + 1
          while index != text.length do
            chattel = Chattel.first_or_create()
            chattel = text[index]
            index = index + 1
          end
        end
      end
      end

      index = index + 1
    end

  end

  def self.parse_from_text
    File.open("links.txt", "r") do |f|
      f.each_line do |line|
        parse_url("http://www.nrsr.sk/web/"+line[0..line.length-4])
      end
    end
  end

end
