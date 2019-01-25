require 'yaml'

#######################################

class Question
  attr_accessor :question, :response
	
  def initialize(question, response)
    @question = question
    @response = response
  end
	
  def getData
    print "#{@question}?: "
    print "Old: #{@response}\nNew: " if !@response.eql?("")
    STDOUT.flush
    response = gets.chomp.strip
    @response = response if !response.eql?("")
  end
end

#######################################

class Survey
  attr_accessor :surveyfields, :title, :filename, :state

  def initialize(file="file.yaml",title="Test Survey",
        datastream="Your name:name\nYour id:stuID")
    @surveyfields = Hash.new()
    @title = title
    @filename = file
    datastream.split(/\n/).each do |line|
      ques, id = line.chomp.split(/\:/) 
      @surveyfields[id] = Question.new(ques,"")
    end
    @state = :empty
  end

  def to_s
    s = "\tFields\tResponse\n#{'=' * 35}\n"
    puts @surveyfields.inspect
    @surveyfields.keys.each_with_index do |f,i|
      s += "#{i+1}. #{f}: [#{@surveyfields[f].response}]\n"
    end
    return s 
  end

  def saveData
    File.open(@filename,mode:"w",encoding:"utf-8") do |f|
      f.puts YAML.dump(@surveyfields)
      puts "Responses saved"
      @state = :saved
    end
  end

  def loadData
    @surveyfields = YAML.load_file(@filename)
    puts "\nResponses loaded from File"
    puts "=" * 35
    puts to_s
    @state = :loaded
  end

  def doSurvey
    @surveyfields.keys.each do |f|
      @surveyfields[f].getData
    end
    @state = :edited
  end

  def editSurvey
    puts to_s
    puts "Choose field number to edit [999 to quit]: "
    STDOUT.flush
    num = gets.chomp.to_i
    if num > 0 && num <= @surveyfields.length
      puts "Editing Field #{num}"
      @surveyfields[@surveyfields.keys[num-1]].getData
    end
    @state = :edited
   end

  def exitSurvey
    if @state == :edited
      print "Save Data? [Y]es [N]o  Choose: "
      STDOUT.flush
      if gets.chomp.downcase[0].eql?('n')
        puts "Goodbye!"
      else
       	saveData
      end
   end
   exit
  end

  def doMenu
    more = true
    while more do
      puts "\n#{@title}\n#{"=" * 35}"
      print "[L]oad data,"       if File.exists?(@filename)
      print "[D]isplay data, "   if @state != :empty
      print "[T]ake survey, "
      puts  "[E]dit data, "      if @state != :empty
      print "[S]ave data, "      if @state == :edited
      print "[Q]uit.\nChoose one: "
      STDOUT.flush
      case gets.chomp.downcase
        when 'l' then loadData
        when 'd' then puts to_s
        when 't' then doSurvey
        when 'e' then editSurvey
        when 's' then saveData
        when 'q' then exitSurvey
        else puts "Unknown response"
      end
    end
  end
end

#######################################

s = Survey.new("survey1.yaml","Course Orientation Survey",
	DATA.readlines.join())
s.doMenu

#######################################

__END__
What is your student ID number:StuID
What is your full name:FullName
What is your nick name:NickName
What email address do you use:Email
What is your GITLab account name:GitLab
Why are you taking this course:Reason
What aspect of computing do you want to study:Goal
What words describe your feelings about mathematics:Math
Have you ever used Git before:Gitexp
Have you ever programmed in Ruby:Rubyexp
Who will be your lab partner for this term:LabPartner
What computer CPU and OS do your use for your homework:Computer