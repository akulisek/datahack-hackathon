target  = "example.txt"

text = File.read(target).split(/\n/)

puts text

functionary = Functionary.first_or_create()
internal_number = InternalNumber.first_or_create()
proclation = Proclamation.first_or_create()
job = Job.first_or_create()

index = 0

while index < text.length do
  f = text[index]
  if f.include? "Interné číslo:" then
    internal_number.value = text[index+1]
    internal_number.save
    index = index + 1
  elsif f.include? "ID oznámenia:" then
    proclation.global_report_id = text[index+1]
    proclation.save
    index = index + 1
  elsif f.include? "meno:" then
    name = text[index+1].select{ |n| !n.include? '.'}
    functionary.first_name = name[1]
    functionary.last_name = name[2]
    functionary.save
    index = index + 1
  elsif f.include? "rodné priezvisko:" then
    functionary.surname_at_birth = text[index+1]
    functionary.save
    index = index + 1
  elsif f.include? "oznámenie za rok::" then
    proclation.year = text[index+1]
    proclation.save
    index = index + 1
  elsif f.include? "oznámenie bolo podané:" then
    proclation.adhibited_at = text[index+1]
    proclation.save
    index = index + 1
  elsif f.include? "vykonávané funkcie:" then
    proclation.administrative_functions = text[index+1]
    proclation.save
    index = index + 1
  elsif f.include? "príjmy za rok 2014:" then
    gains = text[index+1].split(' ')
    gains.each_with_index {|g, i|
      if g.include? "z výkonu verejnej funkcie"
        gain = Gain.first_or_create()
        gain.type = "z výkonu verejnej funkcie"
        gain.value = gains[i-2]
        gain.currency = gains[i-1]
        gain.save
      elsif g.include? "iné"
        gain = Gain.first_or_create()
        gain.type = "ine"
        gain.value = gains[i-2]
        gain.currency = gains[i-1]
        gain.save
      end
    }
    index = index + 1
  elsif f.include? "paušálne náhrady za rok 2014:" then
    reinbursements = text[index+1].split(' ')
    reinbursements.each_with_index {|g, i|
      if g.include? "z výkonu verejnej funkcie"
        reinbursement = Reimbursement.first_or_create()
        reinbursement.type = "z výkonu verejnej funkcie"
        reinbursement.value = gains[i-2]
        reinbursement.currency = gains[i-1]
        reinbursement.save
      elsif g.include? "iné"
        reinbursement = Gain.first_or_create()
        gain.type = "ine"
        gain.value = gains[i-2]
        gain.currency = gains[i-1]
        gain.save
      end
    }
    index = index + 1
  elsif f.include? "ostatné príjmy za rok 2014:" then
    #TODO do not know if like gains of not(if new table or only row in table)
  elsif f.include? "spĺňa podmienky nezlučiteľnosti výkonu funkcie verejného funkcionára s výkonom iných funkcií, zamestnaní alebo činností" then
    if text[index+1].include? "áno" then
      proclation.satisfied_conditions = true
    elsif text[index+1].include? "nie" then
      proclation.satisfied_conditions = false
    end
    proclation.save
    index = index + 1
  elsif f.include? "vykonáva nasledovné zamestnanie v pracovnom pomere alebo obdobnom pracovnom vzťahu alebo štátnozamestnaneckom vzťahu" then
    job.description = text[index+1]
    job.save
    index = index + 1
  elsif f.include? "Dlhodobo plne uvoľnený na výkon verejnej funkcie podľa Zákonníka práce" then
    if f.split(':').include? "nie" then
      proclation.released_in_long_term = false
    elsif f.split(':').include? "áno" then
      proclation.released_in_long_term = true
    end
    proclation.save
  elsif f.include? "vykonáva nasledovnú podnikateľskú činnosť" then
    if text[index+1].split(':').include? "nevykonávam" then
      proclation.entepreneur_activity = false
    elsif f.split(':').include? "vykonávam" then
      proclation.entepreneur_activity = true
    end
    proclation.save
    index = index + 1
  elsif f.include? "počas výkonu verejnej funkcie má tieto funkcie" then
    #TODO maybe administrative function
  elsif f.include? "požitky:" then
    #TODO what is it?
  elsif f.include? "nehnuteľný majetok:" then

    while !text[index].include? "nehnuteľný majetok" do
      index = index + 1

      estate = Estate.first_or_create()
      estate_text = text[index].split(';')

      estate_text.each_with_index { |e, i|
        if e.include? "kat. územie" then
          estate.catastral_area = e.split(' ').select{|t| !t.include? "kat." || !t.include? "územie"}
        elsif e.include? "číslo parcely" then
          estate.parcel_id = e.split(':')[1]
        elsif e.include? "LV č." then
          estate.LV_id = e.split(' ').select{|t| !t.include? "LV" || !t.include? "č."}
        elsif e.include? "podiel" then
          estate.interest = e.split(' ')[2]
        end
      }
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