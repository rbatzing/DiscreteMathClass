require 'set'
require 'benchmark'
include Benchmark

class Group < Set
	def to_s
	  return self.to_a
	end
end


class SetTest
  attr_accessor :sampleSize, :setA, :setB, :setC, :setU
	
  def initialize(number,fraction)
	  @sampleSize = number
	  @setA = Group.new
		@setB = Group.new
		@setC = Group.new
		@setU = Group.new
		
		number.times do |n|
			@setA.add(n) if rand(1000) < fraction
			@setB.add(n) if rand(1000) < fraction
			@setC.add(n) if rand(1000) < fraction
			@setU.add(n)
		end
	end
	
	def countA
		@method = "Method A"
		@abc = @setA.intersection(@setB).intersection(@setC).size
		@ab = (@setA.intersection(@setB) - @setC).size
		@ac = (@setA.intersection(@setC) - @setB).size
		@bc = (@setB.intersection(@setC) - @setA).size
		@a = (@setA - @setB - @setC).size
		@b = (@setB - @setA - @setC).size
		@c = (@setC - @setB - @setA).size
		@u = @setU.size
		@nabc = (@setU - @setA - @setB - @setC).size
  end
		
	def countB
		abi = @setA.intersection(@setB)
		aci = @setA.intersection(@setC)
		bci = @setB.intersection(@setC)
		@method = "Method B"
		@abc = abi.intersection(bci).size
		@ab = abi.size - @abc
		@ac = aci.size - @abc
		@bc = bci.size - @abc
		@a = @setA.size - (abi.size + @ac)
		@b = @setB.size - (abi.size + @bc)
		@c = @setC.size - (aci.size + @bc)
		@u = @setU.size
		@nabc = @setU.size  - (@a + @b + @c + @ab + @ac + @bc + @abc)
  end
	
	def countC
		@method = "Method C"
		@a = @b = @c = @ab= @ac = @bc = @abc = @nabc = @u = 0
		sampleSize.times do |n|
			@u += 1
			@a += 1 if @setA.include?(n) && !@setB.include?(n) && !@setC.include?(n)
			@b += 1 if @setB.include?(n) && !@setA.include?(n) && !@setC.include?(n)	
			@c += 1 if @setC.include?(n) && !@setA.include?(n) && !@setB.include?(n)	

			@ab += 1 if @setA.include?(n) && @setB.include?(n) && !@setC.include?(n)
			@bc += 1 if @setB.include?(n) && @setC.include?(n) && !@setA.include?(n)	
			@ac += 1 if @setA.include?(n) && @setC.include?(n) && !@setB.include?(n)

			@abc += 1 if @setA.include?(n) && @setB.include?(n) && @setC.include?(n)
			@nabc += 1  if !@setA.include?(n) && !@setB.include?(n) && !@setC.include?(n)
		end
	end

	def countD
		@method = "Method D"
		@a = @b = @c = @ab= @ac = @bc = @abc = @nabc = @u = 0
		sampleSize.times do |n|
			@u += 1
			if @setA.include?(n) && !@setB.include?(n) && !@setC.include?(n)
				@a += 1 
			elsif @setB.include?(n) && !@setA.include?(n) && !@setC.include?(n)	
				@b += 1 
			elsif @setC.include?(n) && !@setA.include?(n) && !@setB.include?(n)	
				@c += 1 

			elsif @setA.include?(n) && @setB.include?(n) && !@setC.include?(n)
				@ab += 1
			elsif @setB.include?(n) && @setC.include?(n) && !@setA.include?(n)				
				@bc += 1
			elsif @setA.include?(n) && @setC.include?(n) && !@setB.include?(n)	
				@ac += 1 

			elsif @setA.include?(n) && @setB.include?(n) && @setC.include?(n)
				@abc += 1
			elsif !@setA.include?(n) && !@setB.include?(n) && !@setC.include?(n)
				@nabc += 1
			end
		end
	end


	
	def countE
		@method = "Method E"
		@a = @b = @c = @ab= @ac = @bc = @abc = @nabc = @u = 0
		sampleSize.times do |n|
			@u += 1
			if @setA.include?(n)
				@a += 1
				if @setB.include?(n)
					@a -= 1
					@ab += 1
					if @setC.include?(n)
						@ab -= 1
						@abc += 1
					end
				elsif @setC.include?(n)
					@a -= 1
					@ac += 1
				end
			elsif @setB.include?(n)
				@b += 1
				if @setC.include?(n)
					@b -= 1
					@bc += 1
				end
			elsif @setC.include?(n)
				@c += 1
			else
				@nabc += 1
			end
		end	
	end

	def to_s
	  return <<"msgEnd"
#{@method} =======================================		
nABC:#{@nabc}    Only excluded members
A:   #{@a}    Only members of A
B:   #{@b}    Only members of B
C:   #{@c}    Only members of C
AB:  #{@ab}    Only members of A & B
AC:  #{@ac}    Only members of A & C
BC:  #{@bc}    Only members of B & C
ABC: #{@abc}    Only members of A&B&C
U:   #{@u}    All individuals

msgEnd
	end

end

if __FILE__ == $0
ss = [200,2000,20000]
FRACTION = 250  
ss.each do |s|
puts "SAMPLES SIZE = #{s} =========== "

	t = SetTest.new(s,FRACTION)
	puts t.setU
	t.countA; puts t
	t.countB; puts t
	t.countC; puts t
	t.countD; puts t
	t.countE; puts t

	bmbm(12) do |test|
		test.report("Method A") do 
			1000.times do 
				t.countA 
			end
		end
		test.report("Method B") do 
			1000.times do 
				t.countB 
			end
		end
		test.report("Method C") do 
			1000.times do 
				t.countC 
			end
		end
		test.report("Method D") do 
			1000.times do 
				t.countD 
			end
		end
		test.report("Method E") do 
			1000.times do 
				t.countE 
			end
		end

	end
end
end
