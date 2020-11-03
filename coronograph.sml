(*Reading from file is modified code from courses.softlab.ntua.gr/pl1*)

fun readInt input =
  Option.valOf (TextIO.scanStream (Int.scan StringCvt.DEC) input)

fun readInts input 0 acc = rev acc
  | readInts input i acc = readInts input (i - 1) ((readInt input) :: acc) 

fun prnt [] = print "\n"
  | prnt [a] = (print(Int.toString(a)); prnt [])
  | prnt (h::t) = (print(Int.toString(h)); print " "; prnt t);

fun coronograph_aux V Edges = 
let
  val Graph = Array.array(V, [~1])
  val Parent = Array.array(V, ~1)
  val CycleInfo = Array.array(2, ~1) (*0->cycleFirst,1->cycleLast*)

  fun addEdge x y = 
    (Array.update(Graph, x, y::Array.sub(Graph, x)); 
    Array.update(Graph, y, x::Array.sub(Graph, y)))

  fun removeEdge x y =
  let
    fun remove a [] = []
      | remove a (h::t) = if (h = a) then t else h::(remove a t)
    val g_x = Array.sub(Graph, x)
    val g_y = Array.sub(Graph, y)
  in
    (Array.update(Graph, x, (remove y g_x));
    Array.update(Graph, y, (remove x g_y)))
  end;

  fun createGraph [] = true
    | createGraph [x] = false
    | createGraph (x::y::t) = ((addEdge (x-1) (y-1)); createGraph t)

  fun dfs current = 
  let
    fun dfs_aux current [] = 0
      | dfs_aux current [~1] = 1
      | dfs_aux current (h::t) = if (Array.sub(Parent, h) = ~1) 
                          then (Array.update(Parent, h, current); 
                          dfs h + dfs_aux current t)
                                 else (if (Array.sub(CycleInfo, 0) < 0  andalso
                                 (Array.sub(Parent, current) <> h))
                                 then (
                                 Array.update(Parent, h, current);
                                 Array.update(CycleInfo, 1, current);
                                 Array.update(CycleInfo, 0, h);
                                 dfs_aux current t
                                 )
                                       else (dfs_aux current t)
                                       )
  in
    dfs_aux current (Array.sub(Graph, current))
  end;

  fun getCycle v =
  let
    val prev = Array.sub(Parent, v)
    val last = Array.sub(CycleInfo, 1)

  in
    if (v = Array.sub(CycleInfo, 0)) 
    then ((removeEdge v last);[v])
    else ((removeEdge prev v); (v::getCycle prev))
  end;

  fun getLast a  = Array.sub(CycleInfo, 1)

  fun merge_sort [] = []
    | merge_sort [a] = [a]
    | merge_sort l =
    let
      fun halve [] = ([], [])
        | halve [a] = ([a], [])
        | halve (a :: b :: cs) =
        let
          val (x, y) = halve cs
        in
          (a :: x, b :: y)
        end;
      fun merge [] l = l
        | merge l [] = l
        | merge (h1 :: t1) (h2 :: t2) = if (h1 < h2) then (h1 :: (merge t1 (h2 :: t2))) 
                                        else (h2 :: (merge t2 (h1 :: t1)))
      val (l1, l2) = halve l
    in
          merge (merge_sort l1) (merge_sort l2)
    end;

  fun treeSize current parent = 
  let
    fun treeSize_aux current parent [] = 0
      | treeSize_aux current parent [~1] = 1
      | treeSize_aux current parent (h::t) = if (h <> parent) 
                                             then ((treeSize h current) +
                                             treeSize_aux current parent t)
                                             else (treeSize_aux current parent t)
  in
    treeSize_aux current parent (Array.sub(Graph, current))
  end;

  
  fun treeSizes [] = []
    | treeSizes (root::t) = ((treeSize root root)::(treeSizes t))

  fun print_cycleSize l = (print(Int.toString(length l)); print("\n"); l)


in
  (createGraph Edges;
   Array.update(Parent, 0, 0);
   if ((dfs 0) = V) 
   then (print("CORONA ");
         prnt(merge_sort (treeSizes (print_cycleSize (getCycle (getLast 0))))))
   else (print("NO CORONA\n"))
   )
end;

fun coronograph file =
let
  val inStream = TextIO.openIn file
  val T = readInt inStream
  val _ = TextIO.inputLine inStream

  fun coronoloop 0 = ()
    | coronoloop i = 
    let
      val V = readInt inStream
      val E = readInt inStream
    in
      if (V <> E) 
      then (print("NO CORONA\n"); readInts inStream (2*E) []; coronoloop (i-1))
      else (coronograph_aux V (readInts inStream (2*E) []); coronoloop (i-1))
    end;
in
  coronoloop T
end;
