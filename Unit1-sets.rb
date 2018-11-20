require 'set'

class Group < Set
	def to_s
	  return self.to_a
	end
end


class SetTest
  attr_accessor :sampleSize, :setA, :setB, :setC, :setU
	
  def initialize(number)
	  @sampleSize = number
	  @setA = Group.new
		@setB = Group.new
		@setC = Group.new
		@setU = Group.new
		
		number.times do |n|
			@setA.add(n) if rand(100) < 30
			@setB.add(n) if rand(100) < 30
			@setC.add(n) if rand(100) < 30
			@setU.add(n)
		end
	end
	
	def countA
	  puts <<"msgEnd"
U:   #{@setU.size}    Total sample Size
A:   #{@setA.size}    All members of A
B:   #{@setB.size}    All members of B
C:   #{@setC.size}    All members of C
AB:  #{@setA.intersection(@setB).size}    A & B
AC:  #{@setA.intersection(@setC).size}    A & C
BC:  #{@setB.intersection(@setC).size}    B & C
ABC: #{@setA.intersection(@setB).intersection(@setC).size}  A&B&C
!ABC: #{@setU.size - (@setA.union(@setB).union(@setC).size) }  U - A|B|C
msgEnd
  end

	def countB
		a = b = c = ab= ac = bc = abc = nabc = u = 0
		sampleSize.times do |n|
			u += 1
			if @setA.include?(n)
				a += 1
				if @setB.include?(n)
					b += 1
					ab += 1
					if @setC.include?(n)
						c += 1
						ac += 1
						bc += 1
						abc += 1
					end
				elsif @setC.include?(n)
					c += 1
					ac += 1
				end
			elsif @setB.include?(n)
				b += 1
				if @setC.include?(n)
					c += 1
					bc += 1
				end
			elsif @setC.include?(n)
				c += 1
			else
				nabc += 1
			end
		end	
		
	  puts <<"msgEnd"
U:   #{u}
A:   #{a}
B:   #{b}
C:   #{c}
AB:  #{ab}
AC:  #{ac}
BC:  #{bc}
ABC: #{abc}
!ABC: #{nabc}
msgEnd
	end
	
end

if __FILE__ == $0
  setA = Group.new
  10.times do |i|
    setA.add(i)
  end
	
	puts setA.inspect
	puts setA.size
	puts setA.intersection(Set[1,2,3]).to_s
	
	t = SetTest.new(8000)
	puts t.setU
	puts t.countA
	puts t.countB
end