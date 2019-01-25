n = 1
d= 1

100.times {|i|

   n = n * (365 - i)
   d = d * 365

   puts "%2i -  %8.7f" % [i, 1.0 - (1.0*n /d )]  
   
}