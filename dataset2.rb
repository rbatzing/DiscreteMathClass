require 'csv'

class Dataset
attr_accessor :table, :record

  def initialize(filename)
    @table = CSV.read(filename, headers: true, 
      header_converters: :symbol)
  end

  def summary
    puts "NUMBER OF ROWS: #{@table.count}"
    puts "FIELD NAMES: #{@table.headers}"
    puts "FIRST COLUMN (10): #{@table[@table.headers[0]][0..10]}"
    puts "FIRST ROW: #{@table[0].fields}"
 #       "Medical: #{@table[:ithealth]}"
  end

  def rowCount
    return @table.count
  end

  def fieldNames
    return @table.headers
  end

  def countColumn(fieldnames)
    tally = Hash.new(0)
    @table.each do |line|
      index = ""
      fieldnames.each do |i|
        index += ":#{fieldValue(i,line[i])}"
      end 
      tally[index] += 1
    end
    return tally
  end

  def cost
    return(fieldValue(:price,@record[:price]))
  end
  def expensive?
    return(fieldValue(:price,@record[:price])> 50)
  end

  

  def select
    countsYes = 0
    countsNo = 0
    startTime = Time.now
    @table.each do |line|
      @record = line
=begin
      if ((collegeGrad? || gradStudent? || eastCoast? || westCoast?) &&
           (!(lowSalary? || sales?)))

       if ((eastCoast? && gradStudent? && !lowSalary? && !sales?) || 
          (westCoast? && gradStudent? && !lowSalary? && !sales?) ||
          (eastCoast? && collegeGrad? && !lowSalary? && !sales?) ||
          (westCoast? && collegeGrad? && !lowSalary? && !sales?) ||
          (gradStudent? && !lowSalary? && !sales?) ||
          (collegeGrad? && !lowSalary? && !sales?) ||
          (westCoast? && !lowSalary? && !sales?) ||
          (eastCoast? && !lowSalary? && !sales?))
=end
      if !sales? && !sales? && !sales? && !sales? && !sales?
          countsYes = countsYes + 1
      else
          countsNo = countsNo + 1
      end
    end
    duration = Time.now - startTime
    return([countsYes,countsNo,duration])  
  end

  def fieldValue(field,rawValue)
    case field
    when :age then
      case rawValue
      when "18 to 24" then "18-24"
      when "25 to 34","35 to 44" then "25-44"
      when "45 to 54","55 to 64" then "45-64"
      when ":65 to 74", "75 or older" then "65-older"
      end
        
    when :race then
      case rawValue
      when "White" then "white"
      when "Asian" then "asian"
      else "colored"
      end

    when :education then
      case rawValue
      when "Did not attend school" then  "no school"
      when "Elementary" then "primary school"
      when "Middle school" then "middle school"
      when "Some HighSchool" then "some highSchool"
      when "Graduated from HighSchool" then "highSchool diploma"
      when "Some college" then "undergrad studies"
      when "Bachelor degree" then "undergrad degree"
      when "Some graduate school" then "grad studies"
      when "Graduate degree" then "grad degree"
      end

    when :education_group then
      case rawValue
      when "HighSchool or less" then "no college"
      when "Some college" then "some college"
      when "Bachelor degree" then "college degree"
      when "Post-graduate" then "grad studies"
      end

    when :income then
      case rawValue
      when "$0-$24K" then "<$25K"
      when "$25K-$49K", "$50K-$74K" then "$25K-$74K"
      when "$75K-$99K", "$100K-$149K",
        "$150K and up" then ">$75"
      end

    when :employment then
      case rawValue
      when "Student" then "student"
      when "Employed/Working FT" then "full-time worker"
      when "Employed/Working part-time" then "part-time worker"
      when "Disabled/Unable to work",
        "Not employed/Looking for work",
        "Not employed-NOT looking for work",
        "Retired" then "not working"
      end

    when :job_role then
      case rawValue
      when "Technical/skilled trade" then "skilled trade"
      when "Logistics/transportation" then "logistics"
      when "Licensed professional" then "professional"
      when "Not employed" then "unemployed"
      when "Owner/Exec/Mgmt" then "management"
      when "Sales/service" then "sales"
      when "Admin professional" then "administrator"
      when "Arts/performer" then "artist"
      when "Contract/freelance" then "freelance"
      when "Other" then "other"
      end

    when :region then
      case rawValue
      when "Pacific" then "pacific"
      when "East North Central","West North Central" then "central" 
      when "Middle Atlantic", "New England" then "northeast"
      when "South Atlantic", "West South Central", 
        "East South Central" then "south"
      when "Mountain" then "mountain" 
      else "other"
      end

    when :itwealth then
      case rawValue
      when "0","0.5","1","1.5","2","2.5","3" then "--"
      when "5" then "++"
      else "=="
      end

    when :ithealth then
      case rawValue
      when "5" then "++"
      when "0","0.5","1","1.5","2","2.5" then "--"
      else "=="
      end
 
    when :itcivic then
      case rawValue
      when "0", "0.5", "1", "1.5","2","2.5","3" then "--"
      when "4.5", "5" then "++"
      else "=="
      end

    when :itwork then
      case rawValue
      when "4.5", "5" then "++"
      when "0", "0.5","1","1.5" then "--"
      else "=="
      end

    else # :gender
      rawValue 
    end
  end

end

d = Dataset.new("winemag.csv")
puts "Field Names: #{d.fieldNames}\n\n"
puts "Number of Rows: #{d.rowCount}\n\n"

puts "Prices"
# puts "#{d.table[:price]}"

mean = 0
10.times do |i|
  puts "#{i} #{d.table[i][:price]}"
  mean += d.table[i][:price].to_f
end
mean /= 10

sd =0.0
10.times do |i|
  sd += (mean - d.table[i][:price].to_f)**2
end
sd /= 9
sd = Math.sqrt(sd)

puts "Average =  #{mean} +/- #{sd}"
   


__END__



