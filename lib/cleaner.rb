# Two classes for cleaning data like people and organizations (in future) names.
# 1) Cleaner class is for common methods used all over the place. Like mega_capitalize, mac_mc, etc. If you add methods in it, please make them static for easier usage.
# 2) Cleaner_special class is for special methods used to fix specific issues of certain datasets.
# The methods in there should be static and named the same as the cleaned dataset for convenience.
# --------------------------------------------------------------------------
# USAGE
# * For common cases, when there is nothing to cut off the name, you can use:
#     Cleaner.person_clean("JACKSON, CHARLES K II") => "Charles K. Jackson II"
#
# * If there are data errors, and you need to cut or fix something before normalising,
#   create a static method named the same as the table you are cleaning,
#   perform the needed tweaks then use the person_clean method inside.
#
#     Cleaner.person_clean(name)
#
#   When your special method is ready you can use it like this:
#
#     Cleaner_special.MI_comptroller_salary_2019_clean(name)

def def_val(val, default) # DEFAULT VALUE
  return default if val.nil?
  return val
end

def rgx(w, h = {})                   # FAST REGULAR EXPRESSION BUILDER
  separated = def_val(h[:s], true) # WRAPS THE REGEX IN \b ANCHOR, SYMBOLIZING STRING BOUNDARIES
  dot = def_val(h[:d], true)       # DO YOU WANT A DOT AT THE END?
  d_opt = def_val(h[:d_opt], true) # IS THE DOT OPTIONAL?
  # BUILDING
  return /#{"\\b" if separated}(#{w})#{"\\b" if separated}#{"\\.#{d_opt ? '*' : '+'}" if dot}/i
end

def correct_rgx(name, corrections = {})
  corrections.each do |key, value|
    raise "WRONG TYPE. #{key.class} => #{value.class}. Should be Regexp => String." unless key.instance_of?(Regexp) && value.instance_of?(String)
    name = name.gsub(key, value)
  end
  name
end

def correct(name, corrections = {})
  name = name.to_s
  corrections.each do |key, value|
    raise "WRONG TYPE. #{key.class} => #{value.class}. Should be String => String." unless key.instance_of?(String) && value.instance_of?(String)
    name = name.gsub(rgx(key), value)
  end
  name
end

ABBRS = {
    rgx("Rlty") => 'Realty',
    rgx("SCHLS") => 'Schools',
    rgx("SCH?L?") => 'School',
    rgx("HTS") => 'Heights',
    rgx("SP") => 'Special',
    rgx("ED") => "Education",
    rgx("COOP") => 'Cooperation',
    rgx('DIST') => "District",
    rgx("REGN") => 'Region',
    rgx("Chtr") => 'Charter',
    rgx("Acad") => 'Academy',
    rgx("CORP") => 'Corporation',
    rgx('CONSTRU?C?') => 'Construct',
    rgx('CONSTRUCTIO') => 'Construction',
    rgx('(an?\b.*)\Kcalif(r?na)?') => 'Californian',
    rgx('CHGO') => "Chicago",
    rgx('CALIF(R?NA)?') => 'California',
    rgx('DEV(EL)?|DVLPMN?T') => 'Development',
    rgx('COMM') => 'Community',
    rgx('ENT') => 'Enterprise',
    rgx('EST') => 'Estate',
    rgx('HSE') => 'House',
    rgx('Homeownrs') => 'Homeowners',
    rgx('GRP?|GROU') => 'Group',
    rgx('BK') => 'Bank',
    rgx('PL') => 'Place',
    rgx('SOC') => 'Society',
    rgx('svcs') => 'Services',
    rgx('(SER|SVC)') => 'Service',
    rgx('ASS(OC?|C|N)') => 'Association',
    rgx('HLD') => 'Holding',
    rgx('HLTH') => 'Health',
    rgx('MN?GM?T') => 'Management',
    rgx('STD') => 'Standard',
    rgx('INVES?(TMT)?|INVT?') => 'Investment',
    rgx('INS') => 'Insurance',
    rgx('TRU?') => 'Trustee',
    rgx('A\s*\/\s*C') => 'Air Conditioning',
    rgx('CNCL') => 'Council',
    rgx('CO\.?') => 'Company',
    rgx('CO\.?$') => 'Company',
    rgx('CO(-|\s)OP') => 'Cooperative',
    rgx('CHR') => 'Church',
    rgx('PRTNS') => 'Partners',
    rgx('agcy') => 'Agency',
    rgx('agt?') => 'Agent',
    rgx('asst') => 'Assistant',
    rgx('bldg') => 'Building',
    rgx('BLDR') => 'Builders',
    rgx('BUSI') => 'Business',
    rgx('Dept') => 'Department',
    rgx('EXP') => 'Export',
    rgx('IMP') => 'Import',
    rgx('mfg') => 'Manufacturing',
    rgx('Prop') => 'Property',
    rgx('Apts') => 'Apartments',
    rgx('APTT?') => 'Apartment',
    rgx('NATL?') => 'National',
    rgx('MTG') => 'Mortgage',
    rgx('HSNG') => 'Housing',
    rgx('INS CO') => 'Insurance Company',
    rgx('adv co') => 'Advertising Company',
    rgx('CN?TR') => 'Center',
    rgx('hosp') => 'Hospital',
    rgx('INSP') => 'Inspection',
    rgx('Prof') => 'Professional',
    rgx('INT\'?L') => 'International',
    rgx('Corrl') => 'Correctional',
    rgx('Offcr') => 'Officer',
    rgx('Evalr') => 'Evaluator',
    rgx('Wkr') => 'Worker',
    rgx('Sgt') => 'Sergeant',
    rgx('Asst') => 'Assistant',
    rgx('Admv') => 'Administrative',
    rgx('Admr') => 'Administrator',
    rgx('Cust') => 'Custody',
    rgx('Prog') => 'Program',
    rgx('Proj') => 'Project',
    rgx('Hwy') => 'Highway',
    rgx('Rep') => 'Representative',
    rgx('Cmsn') => 'Commission',
    rgx('Cmte') => 'Committee',
    rgx('bd') => 'Board',
    rgx('Css') => 'Civil Services',
    rgx('Su?pv?r?') => 'Supervisor',
    rgx('DCS') => 'Distributed Control System',
    rgx('St Govt', {d: false}) => 'State Government',
    rgx('Govt') => 'Government',
    rgx('Lrning') => 'Learning',
    rgx('lt') => 'Lieutenant',
    rgx('Nrsg') => 'Nursing',
    rgx('Univ') => 'University',
    rgx('(SPE|SPL|Spct)') => 'Specialist',
    rgx('Engr') => 'Engineer',
    rgx('Dvmt') => 'Development',
    rgx('Rsrch') => 'Research',
    rgx('Lgl') => 'Legal',
    rgx('Acctg') => 'Accounting',
    rgx('pts') => 'Post-Traumatic Stress',
    rgx('rec') => 'Recovery',
    rgx('Cnslr') => 'Counselor',
    rgx('Invgtr') => 'Investigator',
    rgx('Dir') => 'Director',
    rgx('TECH') => 'Technician',
    rgx('SPL') => 'Technician',
    rgx('(MGR|MAN)') => 'Manager',
    rgx('LIC') => 'Licensed',
    rgx('SPCH') => 'Speech',
    rgx('SUPT') => 'Superintendent',
    rgx('COMMUNICATNS') => 'Communications',
    rgx('NETWRK') => 'Nerwork',
    rgx('INSTALLR') => 'Installer',
    rgx('SEC') => 'Secretary',
    rgx('CONSU?LTNT') => 'Consultant',
    rgx('LICENSD') => 'Licensed',
    rgx('(Emplnt|Employmnt)') => 'Employment',
    rgx('(Intrvwr|Interviewr)') => 'Interviewer',
    rgx('Eqp') => 'Equipment',
    rgx('Paramdc') => 'Paramedic',
    rgx('Trng') => 'Training',
    rgx('lvl') => 'Level',
    rgx('Physcl') => 'Physical',
    rgx('Educ') => 'Educational',
    rgx('st') => 'St.'

}.freeze

LEGAL ={
    rgx("inc") => 'Inc.',
    rgx("LTD") => 'Ltd.',
    rgx('M\.?D') => 'M.D.',
    rgx('D\.?O') => 'D.O.',
    rgx('D\.?D\.?S\.?') => 'D.D.S.',
    rgx('D\.?M\.?D\.?') => 'D.M.D.',
    rgx('D\.?P\.?M\.?') => 'D.P.M.',
}
DOWNCASE = ['a', 'an', 'and', 'at', 'as', 'of', 'or', 'on', 'out', 'in', 'the', 'to', 'for', 'from', 'by']

STATES = /\b(A[LKZRAEP]|C[AOT]|D[EC]|F[LM]|G[AU]|HI|I[ADLN]|K[SY]|LA|M[ADEHINOPST]|N[CDEHJMVY]|O[HKR]|P[ARW]|RI|S[CD]|T[NX]|UT|V[AIT]|W[AIVY]|USA?|U\.?S\.?A?\.?A?\.?)\b/i
ROMAN_NR = /\b[IVX]+(?!\.)\b/i

ABBR = /\b(?<!['-])((\w?[^aeoiuy'\-\s]{2,6})|([^aeoiuy'\-\s]{2}\w)|[aeoiuy'\-]{3})(?!['-])\b/i
NOT_ABBR = /\b((\w{2}[-_.,]( |$))|mt|mr|ms|1?st|\d*(nd|rd|th)|co|air|new|b(ay|ig)|one|s[pe]a|oak|old|tax|and|mid|hub|up|two|pro|eye|ann|in|its|the|all)\b\.?/i

BUSINESS = /\b(1st|first|ENT(ERPRISES?)?|(?:inter)?national|associat(ion|es)|assoc?i?a?t?i?o?n?|the|of|to|on|and|by|for|Professionals?|STANDARDS?|((inter)?national\s*)?assoc?(iat(ion|es))?|ASSC|Telephones?|import|export|NEW|hospital|Vet(erinary)?|social|university|institute|college|schools?|Projects?|Academy|CHURCH|Learn(ing)?|Education|bank|police|(Highway)?patrol|loan|Mortgage|Invest(ors?|ments?)?|TRAD(ES?|INGS?)|Credit|Private|Specialt(y|ies)|Couture|Boutique|square|museum|gallery|Imaging|Auctions?|Wholesaler?(s)?|Retail(s|ers?)?|florist|skatium|parks?|GARDENS?|valleys?|Amusements?|CAROUSELs?|Playgrounds?|R(oa)?d|Plantations?|Ports?|Lakes?|rivers?|Waters?|Forests?|falls of|farm(acy)?|corporation|CHIROPRACTIC|center|ctr|business|CITIZENS|merchant|Scissors|windmill|Aqua(tics?)?|health|care|Wax|Bar|Skincare|Beauty|nurs(e|ing)|Massage|Pool|Sport|energy|pilates|(NEURO)?DIAGNOSTICS?|medic(al|ines?)|airlines?|clinic|Healthcare|hair(craft|cut|care)?s?|Barber(shop)?|A\s*\/\s*C|office|Studios?|Salons?|nails|lashes|agen(cy|t)|Assistant|Grocer(y|ies)|firm|Ventures?|uni(on|ted)|Reserves?|Workforces?|MAINTENANCE|at|station|city|county|Borough|Country|villages?|town(ship|house)?s?|street|WATER|SEWER|allstates?|dist(ricts?)?|department|bureau|council|offices?|groups?|divisions?|PARTNER(S(HIP)?)?|commun(ity|ities)?|fund(ings?)?|Savings?|states?|engineering|engines|systems?|stor(ages?|es?)|SUPPL((y|ies)|EMENT)|warehouses?|commerc(e|ial)|constructions?|industr(y|ies)|technologies|Lab(orator(y|ies)|s)?|plumbing|iron|metals?|build(ers?|ings?)|Drilling|Masters?|attic|(re)?Develop(ment|ers?)|interiors?|designs?|arbors?|pharma(ceutica(ls)?|cy)?|auto|Avia(tions?)?(mo(tives?|biles?)|s)?|vehicles?|motors|TRAILERS?|Autonation|BMW|Trucking|transport(s|ation)?|public|accountancy|transit|Wheels?|insurance|security|logistics?|Management|Communications|Portfolio|trust(ee)?|board|Club|union|LEAGUE|society|Foundations?|Heat(ing)?|Authorit(y|ies)|Commiss?ions?|indemnity|Retirement|law|legal|judicial|LAW\s?GROUP|attorney|atty|Consultants?|Equity|COMMONS?|CONTRACT|financ(es?|ial)?|apartments?|homes?|Homeowners|apts?|Parcels?|LANDS?|living|housing|villas?|[hm]otels?|Residen(ti(al|on)|ce)|RENT(als?|s)?|propert(ies|y)|estates?|Realty|restaurants?|Burgers?|Wine|Places?|Bistro|Cabs?|Teams?|committee|cmte|market(ing)?|print(er)?|mail|servic(es?|ing)|co(mp\.?|\.)|company|companies|connected|inspect(ions?|ors?)?|Barber('?s)?|repair|Electriks?|Electr(on?)?(ic(al|it(y|ie)|ian)?)?s?|Electrolysis|Manufacturing|Holdings?|solutions?|Co-op|bail bond(s|ing)?|North|South|East|West|LIMITED|Evictions?|CREMATORY|CEMETERY|Contract(ings?|s)?|U(nited |\.\s?)?S(tates of |\.\s?)?A(merican?|\.\s?)?)\b\.?|&|[a-z]'s\b/i

BUSINESS_SUFFIX = /\b(D\.?P\.?M|D\.?M\.?D|D\.?V\.?M|D\.?O|M\.?D|G\.?P|LTD|L\.?C\.?C\.?C|L\.?C\.?C\.?P|P\.?A\.?C|A\.?P\.?C|B\.?P\.?C|A\.?A\.?O|L\.?L\.?P|L\.?L\.?L\.?P\.?|P\.?L\.?(L\.?)?C|P\.?\s*[CL]\.?|L\.?\s*L\.?\s*C\.?|D\.?D\.?S\.?|INC\.?|N\.?\s*A\.?|L\.?\s*P\.|S\.?A|S\.?S\.?B|O\.?D|P\.?L?\.?(C\.?C?|L))\b\.?/i

PERSON = /\b(Jr|Sr|Esq)\b\.?/i

UNKNOWN = /\b(unknown|any|all|Estate of)\b/i

class Determiner
  def initialize
    # require_relative '../../../procedures/Loki.rb'
    @f_names = []
    @l_names = []
    load_names
  end

  def determine(name)
    if name.split.count > 1 && name.match(UNKNOWN).nil? && name.match(BUSINESS_SUFFIX).nil? && (name.match(BUSINESS).nil? || name.match(PERSON))
      if name_real?(name)
        return "Person"
      else
        return "Unknown"
      end
    elsif (name.match(BUSINESS_SUFFIX)) || (name.match(BUSINESS) && name.match(UNKNOWN).nil?)
      return "Organization"
    else
      return "Unknown"
    end
  end

  def name_real?(name)
    name_split = name.split(/[ \-]/i)
    name_split.map{|e| @f_names.include?(e.upcase)}.include?(true) || name_split.map{|e| @l_names.include?(e.upcase)}.include?(true)
  end

  private
  def load_names
    names_db = Route_noprefix.new(host: DB01, stage_db: 'il_raw')
    names_db.client.query("use #{names_db.stage_db}")
    names_db.client.query('select name from popular_first_names').each{|row| @f_names << row['name'].strip.upcase}
    names_db.client.query('select name from popular_last_names order by count desc').each{|row| @l_names << row['name'].strip.upcase}
    names_db.client.close if names_db
  end
end

class Cleaner

  def self.trim(str)
    return str.to_s.strip.squeeze(' ')
  end

  def self.mac_mc(line)
    return '' if line.to_s == ''
    line.split(' ').map! do |word|
      word = word.sub(/(MAC)([^aeiou]\D*)/i) {"#{Regexp.last_match[1].capitalize}#{Regexp.last_match[2][0].upcase}#{Regexp.last_match[2][1..-1]}" }
      word = word.sub(/(MC)(\D+)/i) {"#{Regexp.last_match[1].capitalize}#{Regexp.last_match[2][0].upcase}#{Regexp.last_match[2][1..-1]}" }
    end.join(' ')
  end

  def self.dewitt(line)
    line.sub(/De *(W|w)itt/, 'DeWitt')
  end

  def self.mega_capitalize(name)
    name = trim(name)
    return '' if name == ''

    name = name.downcase
    name.split(' ').map! do |e|
      if e.match(/\b[a-z]'[a-z]{2,}/i)
        irish_name = e.split("'")
        irish_name[0..1].map!(&:capitalize!)
        irish_name.join("'")
      elsif e.match(/"/)
        e.split(/(")/).map{|j| j.split('-').map(&:capitalize).join('-')}.join('')
      elsif e.match(/\(/)
        e.split(/(\()/).map{|j| j.split('-').map(&:capitalize).join('-')}.join('')
      else
        e.split('-').map(&:capitalize).join('-')
      end
    end.join(' ')
  end

  def self.person_clean(name, reverse = true)
    name = trim(name)
    return '' if name == ''
    name = name.gsub(/[\/\\:<>!?@#%^*()$_+=`"]/i, '') # Removing special chars
    name = name.gsub(/([.,])\s*/i, "\\1 ")
    honor = name.slice!(/\b(mr|mr?s|Dr)\b\.?/i).to_s
    honor = honor.sub(/(?<!\.)$/, '.').capitalize if honor != ''
    honor = honor.sub(/\s*\.\s*/i, ".") if honor != ''

    sr_jr = name.slice!(/\b([sj]r|Esq)\b\s*\.?/i).to_s
    sr_jr = sr_jr.sub(/(?<!\.)$/, '.').capitalize if sr_jr != ''
    sr_jr = sr_jr.sub(/\s*\.\s*/i, ".") if sr_jr != ''
    roman = name.slice!(/\b(I{2,3}|I{0,1}[VX]I{0,3})\b(?!\.)/i).to_s.upcase
    mid_names = []
    name.gsub!(/(?<=\s|^)[a-z]\.?(?=\s|$)/i){|e| mid_names << e.sub(/(?<!\.)$/, '.').to_s.upcase; "" }

    if name.match(',')
      name = name.split(',')
    else
      name = name.split(' ')
    end

    l_name = mac_mc(mega_capitalize(trim(name.delete_at(0).to_s)))
    l_name += " " + mac_mc(mega_capitalize(trim(name.delete_at(0).to_s))) if l_name.match(/^Del?$/i)

    name.map!{ |e| mac_mc(dewitt(mega_capitalize(trim(e)))) }

    if reverse
      trim("#{honor} #{name.join(' ')} #{mid_names.join('')} #{l_name} #{roman} #{sr_jr}")
    else
      trim("#{honor} #{l_name} #{mid_names.join('')} #{name.join(' ')} #{roman} #{sr_jr}")
    end
  end

  # no_cut = ['()', '""', 'AKA', ',$', '_']  # if you want to let some elements in the name, just add them to the params like this.
  def self.cut_org(name, no_cut = [])
    name = trim(name)
    name = name.gsub(/(?<!^)\b((A(LSO |S )?[.\/\\]?)?K(NOWN )?[.\/\\]?AS?[.\/\\]?|D(OING )?[.\/\\]?B(USINESS )?[.\/\\]?AS?[.\/\\]?)\b.*/i, '') unless no_cut.include?('AKA') # Cut everything after AKA/DBA
    name = name.gsub(/(?<!^)\(.*\)/i, '') unless no_cut.include?('()') # Cut everything in parentheses
    name = name.gsub(/(?<!^)".*"/i, '') unless no_cut.include?('""') # Cut everything in brackets
    name = name.gsub(/(?<!^)[\s,<>\/\\|'":;{}`~@#$%^&*()\-_=+]+$/i, '') unless no_cut.include?(',$') # Cut special chars at the end
    name = name.gsub(/[_~^*{}<>]/i, ' ') unless no_cut.include?('_') # Cut special chars at

    name = trim(name)
  end

  def self.org_clean(name)
    name = trim(name)
    return '' if name == ''

    name = cut_org(name)

    wordcount = name.gsub(/[\-#]/i, '').split(' ').count
    if ((wordcount == 1 && name.length > 5 || wordcount > 1) && name.upcase == name) || name.downcase == name
      name = mega_capitalize(name)
      name = name.gsub(STATES){|e| e.to_s.upcase }
      name = name.gsub(ROMAN_NR){|e| e.to_s.upcase }
      name = name.gsub(ABBR){|e| e.to_s.match(NOT_ABBR).nil? ? e.to_s.upcase : e.to_s }
      name = name.gsub(/(?!^)\b(#{DOWNCASE.join('|')})\b/i){|e| e.to_s.downcase }
    end

    business_suffix = name.slice!(/(,\s*)?#{BUSINESS_SUFFIX}/i).to_s
    business_suffix = business_suffix.gsub(/,\s*/i, '')
    business_suffix = trim(business_suffix.upcase)

    name = trim(name)
    name = name.gsub(/[,\-\s]*$/i, '')
    name = trim(name)

    name = correct_rgx(name, ABBRS)
    name = name.gsub(/\s*,\s*/i, ', ')
    name = name.gsub(/\s*\.\s*(?!com|us|gov)/i, '. ')
    name = name.gsub(/\.\s[a-z]/i){|e| e.to_s.upcase }

    name += ", #{business_suffix}" if business_suffix.to_s.length > 0
    # name = name.gsub(/,(?=\s*#{BUSINESS_SUFFIX})/i, '')
    # name = name.gsub(/#{BUSINESS_SUFFIX}/i).each{|e| e.gsub(/\./, '')}
    name = correct_rgx(name, LEGAL)
    name = name.gsub(/,\s*/i, ', ')
    trim(name)
  end
end

class Cleaner_special
  def self.az_school_clean(name) #db01.usa_raw.AZ_school_AIMS_scores__schools
    name = Cleaner.trim(name)
    return '' if name == ''

    name.gsub(/\b([b-z]|sr|jr|st)\.?(?=\s|$)/i, "\\1.")
  end

  def self.MI_comptroller_salary_2019_clean(name)
    name = Cleaner.trim(name)
    return '' if name == ''

    name = name.gsub(/\b([a-z]{2,})'/i, "\\1")
    Cleaner.person_clean(name)
  end

  def self.az_employee_salary(name)
    name = name.to_s
    return '' if name == ''
      name = name.gsub(/\(.*\)/i, '').gsub(/\*.*$/i, '').gsub(/\b\d+\s*Hrs?\b/i, '').gsub(/\b(Level\s*)?[IV\d]+$/i, '').gsub(/\b(Level\s*)\d+\b/i, '').gsub(/-\s*(Seasonal|Pt|Nb)/i, '').gsub(/\bsr\b/i, "Senior").gsub(/[\-_\s+*]+$/i, '')
    name = correct_rgx(name, ABBRS)
    Cleaner.trim(name)
  end

  @mn_psd_abbrs = {
      "SCHLS" => 'Schools',
      "SCH?L?" => 'School',
      "HTS" => 'Heights',
      "SP" => 'Special',
      "ED" => "Education",
      "COOP" => 'Cooperation',
      'DIST' => "District",
      "REGN" => 'Region',
      "Chtr." => 'Charter',
      "Acad" => 'Academy',

  }
  def self.mn_psd(name)
    name = Cleaner.trim(name)
    name = correct(name, @mn_psd_abbrs)
    name = Cleaner.mac_mc(Cleaner.mega_capitalize(name))

    name = name.gsub(/\b(#{DOWNCASE.join('|')})\b(?!\.)/i){ |e| e.downcase }
    name = name.gsub(/(?<=\.)[a-z]/i){|e| e.upcase }

    name = name.gsub(/,?\s+inc\b\.?/i, '')
    name.gsub(rgx("(PUBLIC SCHOOLS?( DISTRICT)?)"), "PSD")
  end

  # db01.usa_raw.allocation_for_section_188004a_care_act
  def self.schools_from_allocation(name)
    if name.include?('(The)')
      name = name.gsub(/ \(The\)/, '')
      name = 'the ' + name
    end
    name = name.gsub($proper_noun_lowercase_words_regex, &:downcase)
    name = name.gsub("'S", "'s")
    name = name.gsub(/--?/, ' - ')
    name = name.gsub('Prgm', 'Program')
    name = name.gsub('Tri - ', 'Tri-')
    name = name.gsub(/\ba.\b/, &:upcase)
    name = name.gsub(/\s+/, ' ')
    name.strip
  end

  def self.arizona_professional_licenseing_business(name)
    name = Cleaner.trim(name)
    return '' if name == ''
    if name.match?(/Branch$|PLLC\b|Inc\.?\b(?=.+\d.+)/)
      parts = name.partition(/\b(Inc\.?|LTD\.?|P?LLC\.?|L\.L\.C\.|L\.L\.C\.(?=,))/i)
      "#{Cleaner.org_clean(parts[0] + parts[1])}#{', ' unless parts[2][0] == ',' || parts[2][0].nil?}#{Cleaner.org_clean(parts[2])}"
      else
      Cleaner.org_clean(name)
    end
  end
end
