require 'benchmark'
include Benchmark
require 'csv'

class Dataset
	attr_accessor :table, :record, :stats, :varieties,
    :pricevar

  def initialize(filename)
	@table = CSV.read(filename, headers: true, header_converters: :symbol)

	@stats = Hash.new
	[:pts, :price].each do |p|
	   @stats[p] = statistics(@table[p])
	end
	@varieties = Hash.new(0)
	@table[:variety].each do |v|
		@varieties[v] += 1
	end
	@stats[:varieties] = statistics(@varieties.values)

	@pricevar = Hash.new(0)
    @table.each do |rec|
		@pricevar[rec[9]] += rec[5].to_f/ @varieties[rec[9]]
	end
	@stats[:pricevar] = statistics(@pricevar.values)
  end
  
  def statistics(data)
	count = 0
	vector = Array.new
	min = nil
	max = nil
	mean = 0
	sd = 0
	data.each do |x|
		if !x.nil?
			y = x.to_f
			vector << y
			max = y if max.nil? || y > max
			min = y if min.nil? || y < min
			mean += y
			sd += y ** 2
			count += 1
		end
	end	
	vector.sort!
	q5 = vector[count/20]
	q50 = vector[count/2]
	q95 = vector[95*count/100]
	mean /= count
	sd = Math.sqrt((sd - count * mean * mean) / count - 1)
	return [mean,sd, min,q5,q50,q95,max,count]
  end

  def summary
    puts "NUMBER OF ROWS: #{@table.count}"
    puts "FIELD NAMES: #{@table.headers}"

    puts ("%10s" + " %8s" * 8) %
      [:parameter,:mean,:sd, :min,:q5,:q50,:q95,:max,:count]
	
	@stats.keys.sort.each do |k|
		puts ("%10s" + (" %8.2f" * 7) + " %8i") %
			[k, @stats[k]].flatten
	end
	
#	puts "FIRST COLUMN (10): #{@table[@table.headers[0]][0..10]}"
#    puts "FIRST ROW: #{@table[0].fields}"
 #       "Medical: #{@table[:ithealth]}"
  end

  def fieldNames
    return @table.headers
  end
  
  def rowCount
    return @table.count
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

=begin
# Headers: 
 0:id, 1:cntry, 2:descr, 3:label, 4:pts, 5:price,
 6:prov, 7:reg_1, 8:reg_2, 9:variety, 10:winery

Results:
 parameter  mean      sd      count  
			min       q5      q50      q95      max 
=======================================================
     price  33.13    36.31   137235
			4.00     10.00   24.00   80.00  2300.00
------------------------------------------------------
  pricevar  22.86    14.29     632
			0.00     8.80    20.00    45.03   150.00      
------------------------------------------------------
       pts  87.89     3.06    150930
	        80.00    83.00    88.00    93.00   100.00   
------------------------------------------------------
 varieties  238.81  1215.43    632
              1.00     1.00     8.00   982.00 14482.00 
=======================================================  
=end

  def fuzzyAND(*fuzzyArray)
	return fuzzyArray.min
  end
  
  def fuzzyOR(*fuzzyArray)
	return fuzzyArray.max
  end
  
  def fuzzyNEG(val)
    return 1.00 - val
  end
  
# -----------------------------------------
 
  def fuzzyE
    value =  (@record[5].to_f - 10) / 70.00
	if value > 1
	    value = 1.00
	elsif value < 0
		value = 0.00
	end
	return value
  end

  #---------------------------------------------
  # These functions needs your code
  def fuzzyQ
    value =  1.00
    return value
  end

  def fuzzyC
	  value = 1.00
    return value
  end
  
  def fuzzyV
    value = 1.00
    return value
  end
  
  def fuzzySelect
    countsYes = 0
    countsNo = 0
    @table.each do |line|
      @record = line

      f = fuzzyOR(
        fuzzyAND(fuzzyE,fuzzyNEG(fuzzyQ),fuzzyC),
        fuzzyAND(fuzzyE, fuzzyQ,fuzzyNEG(fuzzyC)),
        fuzzyAND(fuzzyNEG(fuzzyE),fuzzyQ,fuzzyC),
        fuzzyAND(fuzzyNEG(fuzzyE),fuzzyQ,fuzzyNEG(fuzzyC)),  
        fuzzyAND(fuzzyNEG(fuzzyE),fuzzyQ,fuzzyC),
        fuzzyAND(fuzzyNEG(fuzzyE),fuzzyQ,fuzzyNEG(fuzzyC)),			
        fuzzyAND(fuzzyC,fuzzyNEG(fuzzyQ),fuzzyE),
        fuzzyAND(fuzzyNEG(fuzzyC),fuzzyQ,fuzzyNEG(fuzzyE)), 
        fuzzyAND(fuzzyNEG(fuzzyV),fuzzyE),
        fuzzyAND(fuzzyV,fuzzyNEG(fuzzyE)))
      if f >= 0.78
      
          countsYes += 1
      else
          countsNo += 1
      end
    end
    return([countsYes,countsNo])  
  end

  def fuzzyLogicCounts
      countE = countL = countP = countQ =
        countC = countX = countV = countI = 
        countNotE = countNotQ = countNotC =
        countNotV = 0
      threshold = 0.99
      
    @table.each do |line|
      @record = line
      if fuzzyE >= threshold
        countE += 1
      else
        countNotE += 1
        countL += 1 if fuzzyNEG(fuzzyE) >= threshold
      end
      
      if fuzzyQ >= threshold
        countQ += 1
      else
        countNotQ += 1
        countP += 1 if fuzzyNEG(fuzzyQ) >= threshold
      end
      
      if fuzzyC >= threshold
        countC += 1
      else
        countNotC += 1
        countX += 1 if fuzzyNEG(fuzzyC) >= threshold
      end

      if fuzzyV >= threshold
        countV += 1
      else        
        countNotV += 1
        countI += 1 if fuzzyNEG(fuzzyV) >= threshold
      end
    end
    puts "E: %8i (%4.3f)\t !E: %8i\t L: %8i\n" % 
      [countE,1.0 *countE/(countE+countNotE),countNotE, countL]
    puts "Q: %8i (%4.3f)\t !Q: %8i\t P: %8i\n" %
      [countQ,1.0*countQ/(countQ+countNotQ),countNotQ, countP]
    puts "C: %8i (%4.3f)\t !C: %8i\t X: %8i\n" %
      [countC,1.0*countC/(countC+countNotC),countNotC,countX]
    puts "V: %8i (%4.3f)\t !V: %8i\t I: %8i\n" %
      [countV,1.0*countV/(countV+countNotV),countNotV,countI]
  end
  
# ===================================================

# E = Most expensive wines
  def e?
    return @record[5].to_f > 79.99
  end 
    
# L = Least expensive wines
  def l?
    return @record[5].to_f < 10.01
  end

# ---------------------------------------
# These functions need your code
# Q = Highest quality wines
  def q?
    return true
  end

# P = Poorest quality wines
  def p?
    return true
  end

# C = Most common type of grapes
  def c?
    return true
  end

# X = Least common type of grapes
  def x?
    return true
  end

# V = Most valuable type of grapes
  def v?
    return true
  end

# I = least valuable type of grapes
  def i?
    return true
  end

  def select
    countsYes = 0
    countsNo = 0
    @table.each do |line|
      @record = line

      if (e? && p? && c?) || (e? && q? && x?) ||
          (l? && q? && c?) || (l? && q? && x?) ||  
          (!e? && q? && c?) || (!e? && q? && !c?) || 
          (c? && p? && e?) || (x? && q? && l?) || 
          (i? && e?) || (v? && l?)
        countsYes = countsYes + 1
      else
        countsNo = countsNo + 1
      end
    end
    return([countsYes,countsNo])  
  end

  def logicCounts
      countE = countL = countP = countQ =
        countC = countX = countV = countI = 
        countNotE = countNotC = countNotQ =
        countNotV = 0
    @table.each do |line|
      @record = line
      countE += 1 if e?
      countNotE += 1 if !e?
      countL += 1 if l?
      
      countQ += 1 if q?
      countNotQ += 1 if !q?
      countP += 1 if p?
      
      countC += 1 if c?
      countNotC += 1 if !c?
      countX += 1 if x?

      countV += 1 if v?
      countNotV += 1 if !v?
      countI += 1 if i?
    end
    puts "E: %8i (%4.3f)\t !E: %8i\t L: %8i\n" % 
      [countE,1.0*countE/(countE+countNotE), countNotE, countL]
    puts "Q: %8i (%4.3f)\t !Q: %8i\t P: %8i\n" %
      [countQ,1.0*countQ/(countQ+countNotQ),countNotQ, countP]
    puts "C: %8i (%4.3f)\t !C: %8i\t X: %8i\n" %
      [countC,1.0*countC/(countC+countNotC),countNotC, countX]
    puts "V: %8i (%4.3f)\t !V: %8i\t I: %8i\n" %
      [countV,1.0*countV/(countV+countNotV),countNotV, countI]
  end
end

d = Dataset.new("winemag.csv")
d.summary
puts "\nDiscrete Logic Tally"
d.logicCounts
puts "\nFuzzy Logic Tally"
d.fuzzyLogicCounts

bmbm(15) do |test|
  test.report("\nDiscrete logic") do
    print "Selected: %i,  Rejected: %i\nTime used:" % d.select
    9.times do
      d.select
    end
  end
  test.report("\nFuzzy logic") do
    print "Selected: %i,  Rejected: %i\nTime used:" % d.fuzzySelect
    9.times do
      d.fuzzySelect
    end
  end
    
end
__END__



