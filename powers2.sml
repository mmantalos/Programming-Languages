fun expand [] k = []
  | expand l 0 = l
  | expand (0::t) k = (0::(expand t k))
  | expand (n::t) k = expand ((n-1)::(n-1)::t) (k-1)

fun binary 0 p = []
  | binary n p = if ((n mod 2) = 1) then (p::(binary (n div 2) (p+1))) else (binary (n div 2) (p+1)) 

fun count n [] = 0
  | count n (h::t) = if (h = n) then (1 + (count n t)) else 0

fun remove n [] = []
  | remove n (h::t) = if (h = n) then (remove n t) else (h::t)

fun reform [] n = []
  | reform (h::t) n = if (h = n) 
                      then ((count n (h::t))::(reform (remove n (h::t)) (n+1)))
                      else (0::(reform (h::t) (n+1)))

fun prnt [] = print ""
  | prnt [a] = (print(Int.toString(a)))
  | prnt (h::t) = (print(Int.toString(h)); print ","; prnt t);

fun powers2_aux n k = 
        let 
          val b = (binary n 0)
          val b_length = (length b)
        in 
          print "[";
          prnt (if ((k > n) orelse (k < b_length)) then [] 
                else reform (expand b (k - b_length)) 0);
          print "]\n"
        end
 
(*The following code was found on courses.softlab.ntua.gr/pl1*)       
fun parse file =
    let
	(* A function to read an integer from specified input. *)
        fun readInt input = 
	    Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) input)

	(* Open input file. *)
    	val inStream = TextIO.openIn file

        (* Read an integer (number of countries) and consume newline. *)
	val n = readInt inStream
	val _ = TextIO.inputLine inStream

        (* A function to read N integers from the open file. *)
	fun readInts 0 acc = rev acc (* Replace with 'rev acc' for proper order. *)
	  | readInts i acc = readInts (i - 1) (readInt inStream :: acc)
    in
   	readInts (2*n) []
    end

fun solve [] = powers2_aux 0 0
  | solve [N] = powers2_aux 0 0
  | solve [N,K] = powers2_aux N K
  | solve (N::K::t) = ((powers2_aux N K); (solve t));

fun powers2 fileName = (solve (parse fileName))
			 
