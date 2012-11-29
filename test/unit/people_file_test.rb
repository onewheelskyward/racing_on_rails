require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PersonFileTest < ActiveSupport::TestCase  
  def test_import
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:discipline, :name => "Track")
    FactoryGirl.create(:number_issuer)

    team = Team.create!(:name => "Sorella Forte Elite Team")
    event = SingleDayEvent.create!(:date => 1.years.ago)
    senior_men = FactoryGirl.create(:category)
    result = event.races.create!(:category => senior_men).results.create!(:team => team)
    team.aliases.create!(:name => "Sorella Forte")
    assert_equal(0, team.names(true).size, "names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")

    tonkin = FactoryGirl.create(
      :person, 
      :first_name => "Erik", 
      :last_name => "Tonkin", 
      :member_from => nil, 
      :member_to => nil,
      :ccx_category => "A",
      :road_category => "1",
      :track_category => "5",
      :notes => 'Spent Christmans in Belgium',
      :login => "sellwood"
    )

    file = File.new("#{File.dirname(__FILE__)}/../files/membership/55612_061202_151958.csv, attachment filename=55612_061202_151958.csv")
    people = PeopleFile.new(file).import(true)
    
    assert_equal([4, 1], people, 'Number of people created and updated')
    
    assert_equal(1, Person.find_all_by_name('Erik Tonkin').size, 'Erik Tonkins in database after import')
    tonkin.reload
    assert_equal('Erik Tonkin', tonkin.name, 'Tonkin name')
    assert_equal_dates('1973-05-07', tonkin.date_of_birth, 'Birth date')
    assert_equal('F', tonkin.gender, 'gender')
    assert_equal('Judy@alum.dartmouth.org', tonkin.email, 'email')
    assert_equal("6272 Crest Ct. E.#{$INPUT_RECORD_SEPARATOR}Apt. 45", tonkin.street)
    assert_equal('Wenatchee', tonkin.city, 'city')
    assert_equal('WA', tonkin.state, 'state')
    assert_equal('97058', tonkin.zip, 'ZIP')
    assert_equal('541-296-9911', tonkin.home_phone, 'home_phone')
    assert_equal('IV Senior', tonkin.road_category, 'Road cat')
    assert_equal("5", tonkin.track_category, 'track cat')
    assert_equal('A', tonkin.ccx_category, 'Cross cat')
    assert_equal('Expert Junior', tonkin.mtb_category, 'MTB cat')
    assert_equal('Physician', tonkin.occupation, 'occupation')
    assert_equal("Sorella Forte Elite Team", tonkin.team_name, 'Team')
    notes = %Q{Spent Christmans in Belgium
Receipt Code: 2R2T6R7
Confirmation Code: 462TLJ7
Transaction Payment Total: 32.95
Registration Completion Date/Time: 11/20/06 10:04 AM
Disciplines: Road/Track/Cyclocross
Donation: 10
Downhill/Cross Country: Downhill}
    assert_equal(notes, tonkin.notes, 'notes')
    assert(tonkin.print_card?, 'Tonkin.print_card? after import')
    assert_nil(tonkin.card_printed_at, 'Tonkin.card_printed_at after import')
    assert_equal "sellwood", tonkin.login, "Should not reset login after import"

    sautter = Person.find_all_by_name('C Sautter').first
    assert_equal('C Sautter', sautter.name, 'Sautter name')
    assert_equal_dates('1966-01-06', sautter.date_of_birth, 'Birth date')
    assert_equal('M', sautter.gender, 'gender')
    assert_equal('Cr@comcast.net', sautter.email, 'email')
    assert_equal('262 SW 4th Ave', sautter.street)
    assert_equal('lake oswego', sautter.city, 'city')
    assert_equal('OR', sautter.state, 'state')
    assert_equal('97219', sautter.zip, 'ZIP')
    assert_equal('503-671-5743', sautter.home_phone, 'phone')
    assert_equal('IV Master', sautter.road_category, 'Road cat')
    assert_equal('IV Master', sautter.track_category, 'track cat')
    assert_equal('A Master', sautter.ccx_category, 'Cross cat')
    assert_equal('Sport Master 40+', sautter.mtb_category, 'MTB cat')
    assert_equal('Engineer', sautter.occupation, 'occupation')
    assert_equal('B.I.K.E. Hincapie', sautter.team_name, 'Team')
    notes = %Q{Receipt Code: 922T4R7\nConfirmation Code: PQ2THJ7\nTransaction Payment Total: 22.3\nRegistration Completion Date/Time: 11/20/06 09:23 PM\nDisciplines: Road/Track/Cyclocross & Mtn Bike \nDonation: 0\nDownhill/Cross Country: Cross country\nSinglespeed: No\nOther interests: Marathon XC Short track XC}
    assert_equal(notes, sautter.notes, 'notes')
    assert(sautter.print_card?, 'sautter.print_card? after import')
    assert_nil(sautter.card_printed_at, 'sautter.card_printed_at after import')
    
    ted_gresham = Person.find_by_name('Ted Greshsam')
    assert_equal(nil, ted_gresham.team, 'Team')
    
    camden_murray = Person.find_by_name('Camden Murray')
    assert_equal(nil, camden_murray.team, 'Team')
    assert(camden_murray.created_by.name["55612_061202_151958.csv, attachment filename=55612_061202_151958.csv"], "created_by name")
    
    team = Team.find_by_name("B.I.K.E. Hincapie")
    assert(team.created_by.name["55612_061202_151958.csv, attachment filename=55612_061202_151958.csv"], "created_by name")
    
    assert_equal(1, Team.count(:conditions => { :name => "Sorella Forte Elite Team"} ), "Should have one Sorella Forte in database")
    team = Team.find_by_name("Sorella Forte Elite Team")
    assert_equal(0, team.names(true).size, "names")
    assert_equal(1, team.aliases(true).size, "Aliases")
    assert_equal(["Sorella Forte"], team.aliases.map(&:name).sort, "Team aliases")
  end
  
  def test_excel_file_database
    FactoryGirl.create(:discipline, :name => "Cyclocross")
    FactoryGirl.create(:discipline, :name => "Downhill")
    FactoryGirl.create(:discipline, :name => "Mountain Bike")
    FactoryGirl.create(:discipline, :name => "Road")
    FactoryGirl.create(:number_issuer)
    
    # Pre-existing people
    brian = Person.create!(
      :last_name =>'Abers',
      :first_name => 'Brian',
      :gender => 'M',
      :email =>'brian@sportslabtraining.com',
      :member_from => '2004-02-23',
      :member_to => Date.new(Time.zone.today.year + 1, 12, 31),
      :date_of_birth => '1965-10-02',
      :notes => 'Existing notes',
      :road_number => '824',
      :dh_number => "117"
    )

    rene = Person.create!(
      :last_name =>'Babi',
      :first_name => 'Rene',
      :gender => 'M',
      :email =>'rbabi@rbaintl.com',
      :member_from => '2000-01-01',
      :team_name => 'RBA Cycling Team',
      :road_category => '4',
      :road_number => '190A',
      :date_of_birth => '1899-07-14'
    )
    rene.reload
    assert_equal('190A', rene.road_number(true), 'Rene existing DH number')
    
    scott = Person.create!(
      :last_name =>'Seaton',
      :first_name => 'Scott',
      :gender => 'M',
      :email =>'sseaton@bendcable.com',
      :member_from => '2000-01-01',
      :team_name => 'EWEB',
      :road_category => '3',
      :date_of_birth => '1959-12-09',
      :license => "1516"
    )
    number = scott.race_numbers.create!(:value => '422', :year => Time.zone.today.year - 1)
    number = RaceNumber.first(:conditions => ['person_id=? and value=?', scott.id, '422'])
    assert_not_nil(number, "Scott\'s previous road number")
    assert_equal(Discipline[:road], number.discipline, 'Discipline')
    
    # Dupe Scott Seaton should be skipped because of different license
    Person.create!(
      :last_name =>'Seaton',
      :first_name => 'Scott'
    )

    file = File.new("#{File.dirname(__FILE__)}/../files/membership/database.xls")
    people = PeopleFile.new(file).import(true)
    
    assert_equal([2, 3], people, 'Number of people created and updated')
    
    all_quinn_jackson = Person.find_all_by_name('quinn jackson')
    assert_equal(1, all_quinn_jackson.size, 'Quinn Jackson in database after import')
    quinn_jackson = all_quinn_jackson.first
    assert_equal('M', quinn_jackson.gender, 'Quinn Jackson gender')
    assert_equal('quinn3769@yahoo.com', quinn_jackson.email, 'Quinn Jackson email')
    assert_equal_dates('2006-04-19', quinn_jackson.member_from, 'Quinn Jackson member from')
    assert_equal_dates(Time.zone.now.end_of_year, quinn_jackson.member_to, 'Quinn Jackson member to')
    assert_equal_dates('1969-01-01', quinn_jackson.date_of_birth, 'Birth date')
    assert_equal('interests: 14', quinn_jackson.notes, 'Quinn Jackson notes')
    assert_equal('1416 SW Hume Street', quinn_jackson.street, 'Quinn Jackson street')
    assert_equal('Portland', quinn_jackson.city, 'Quinn Jackson city')
    assert_equal('OR', quinn_jackson.state, 'Quinn Jackson state')
    assert_equal('97219', quinn_jackson.zip, 'Quinn Jackson ZIP')
    assert_equal('503-768-3822', quinn_jackson.home_phone, 'Quinn Jackson phone')
    assert_equal('nurse', quinn_jackson.occupation, 'Quinn Jackson occupation')
    assert_equal('120', quinn_jackson.xc_number(true), 'quinn_jackson xc number')
    assert_not_nil quinn_jackson.created_by, "Person#created_by should be set"
    assert_not_nil quinn_jackson.updated_by, "Person#updated_by should be set"
    number = quinn_jackson.race_numbers.detect { |n| n.value == "120" }
    assert(number.updated_by.name["membership/database.xls"], "updated_by expected to include file name but was #{number.updated_by}")
    assert(!quinn_jackson.print_card?, 'quinn_jackson.print_card? after import')
    
    all_abers = Person.find_all_by_name('Brian Abers')
    assert_equal(1, all_abers.size, 'Brian Abers in database after import')
    brian_abers = all_abers.first
    assert_equal('M', brian_abers.gender, 'Brian Abers gender')
    assert_equal('thekilomonster@verizon.net', brian_abers.email, 'Brian Abers email')
    assert_equal_dates('2004-02-23', brian_abers.member_from, 'Brian Abers member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), brian_abers.member_to, 'Brian Abers member to')
    assert_equal_dates('1965-10-02', brian_abers.date_of_birth, 'Birth date')
    assert_equal("Existing notes\ninterests: 1247", brian_abers.notes, 'Brian Abers notes')
    assert_equal('5735 SW 198th Ave', brian_abers.street, 'Brian Abers street')
    road_numbers = RaceNumber.all( :conditions => [ 
        "person_id = ? and discipline_id = ? and year = ?", brian_abers.id, Discipline[:road].id, RacingAssociation.current.year
      ])
    assert_equal(2, road_numbers.size, 'Brian Abers road_numbers')
    assert road_numbers.any? { |number| number.value == "824" }, "Should preseve Brian Abers road number"
    assert road_numbers.any? { |number| number.value == "825" }, "Should add Brian Abers new road number"
    assert_equal('117', brian_abers.dh_number, 'Brian Abers dh_number')
    assert(!brian_abers.print_card?, 'brian_abers.print_card? after import')
    
    all_heidi_babi = Person.find_all_by_name('heidi babi')
    assert_equal(1, all_heidi_babi.size, 'Heidi Babi in database after import')
    heidi_babi = all_heidi_babi.first
    assert_equal('F', heidi_babi.gender, 'Heidi Babi gender')
    assert_equal('hbabi77@hotmail.com', heidi_babi.email, 'Heidi Babi email')
    assert_equal_dates(Time.zone.today, heidi_babi.member_from, 'Heidi Babi member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), heidi_babi.member_to, 'Heidi Babi member to')
    assert_equal_dates('1977-01-01', heidi_babi.date_of_birth, 'Birth date')
    assert_equal("interests: 134", heidi_babi.notes, 'Heidi Babi notes')
    assert_equal('11408 NE 102ND ST', heidi_babi.street, 'Heidi Babi street')
    assert_equal('360-896-3827', heidi_babi.home_phone, 'Heidi home phone')
    assert_equal('360-696-9272', heidi_babi.work_phone, 'Heidi work phone')
    assert_equal('360-696-9398', heidi_babi.cell_fax, 'Heidi cell/fax')
    assert(heidi_babi.print_card?, 'heidi_babi.print_card? after import')
    
    all_rene_babi = Person.find_all_by_name('rene babi')
    assert_equal(1, all_rene_babi.size, 'Rene Babi in database after import')
    rene_babi = all_rene_babi.first
    assert_equal('M', rene_babi.gender, 'Rene Babi gender')
    assert_equal('rbabi@rbaintl.com', rene_babi.email, 'Rene Babi email')
    assert_equal_dates('2000-01-01', rene_babi.member_from, 'Rene Babi member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), rene_babi.member_to, 'Rene Babi member to')
    assert_equal_dates('1899-07-14', rene_babi.date_of_birth, 'Birth date')
    assert_equal(nil, rene_babi.notes, 'Rene Babi notes')
    assert_equal('1431 SE Columbia Way', rene_babi.street, 'Rene Babi street')
    assert(rene_babi.print_card?, 'rene_babi.print_card? after import')
    assert_equal('190A', rene_babi.road_number, 'Rene road_number')
    
    all_scott_seaton = Person.find_all_by_name('scott seaton')
    assert_equal(2, all_scott_seaton.size, 'Scott Seaton in database after import')
    scott_seaton = all_scott_seaton.detect { |p| p.license == "1516"}
    assert_equal('M', scott_seaton.gender, 'Scott Seaton gender')
    assert_equal('sseaton@bendcable.com', scott_seaton.email, 'Scott Seaton email')
    assert_equal_dates('2000-01-01', scott_seaton.member_from, 'Scott Seaton member from')
    assert_equal_dates(Date.new(Time.zone.today.year, 12, 31), scott_seaton.member_to, 'Scott Seaton member to')
    assert_equal_dates('1959-12-09', scott_seaton.date_of_birth, 'Birth date')
    assert_equal('interests: 3146', scott_seaton.notes, 'Scott Seaton notes')
    assert_equal('1654 NW 2nd', scott_seaton.street, 'Scott Seaton street')
    assert_equal('Bend', scott_seaton.city, 'Scott Seaton city')
    assert_equal('OR', scott_seaton.state, 'Scott Seaton state')
    assert_equal('97701', scott_seaton.zip, 'Scott Seaton ZIP')
    assert_equal('541-389-3721', scott_seaton.home_phone, 'Scott Seaton phone')
    assert_equal('firefighter', scott_seaton.occupation, 'Scott Seaton occupation')
    assert_equal("Hutch's Bend", scott_seaton.team_name, 'Scott Seaton team should be updated')
    assert(!scott_seaton.print_card?, 'sautter.print_card? after import')
    
    scott.race_numbers.create(:value => '422', :year => Time.zone.today.year - 1)
    number = RaceNumber.first(:conditions => ['person_id=? and value=?', scott.id, '422'])
    assert_not_nil(number, "Scott\'s previous road number")
    assert_equal(Discipline[:road], number.discipline, 'Discipline')
  end
  
  def test_import_duplicates
    existing_person_with_login = FactoryGirl.create(:person_with_login, :name => "Erik Tonkin")
    existing_person = FactoryGirl.create(:person, :name => "Erik Tonkin")
    
    file = File.new("#{File.dirname(__FILE__)}/../files/membership/duplicates.xls")
    people_file = PeopleFile.new(file)
    
    people_file.import(true)
    
    assert_equal(1, people_file.created, 'Number of people created')
    assert_equal(0, people_file.updated, 'Number of people updated')
    assert_equal(1, people_file.duplicates.size, 'Number of duplicates')

    duplicate = people_file.duplicates.first
    assert existing_person.in?(duplicate.people), "Should include person with same name"
    assert existing_person_with_login.in?(duplicate.people), "Should include person with same name"
    assert_equal "Portland", duplicate.new_attributes["city"], "city"
    assert duplicate.new_attributes.values.none?(&:nil?), "Should be no nil values in #{duplicate.new_attributes}"
  end
end
