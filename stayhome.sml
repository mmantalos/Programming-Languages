fun prnt [] = print "\n"
  | prnt (h::t) = (print(h);prnt t)

fun input inStream ob s v g a N i M = 
let 
  val c = TextIO.inputN (inStream, 1)
in
  if c = "." then input inStream (0::ob) s v g a N (i+1) M else
   (if c = "X" then input inStream (1::ob) s v g a N (i+1) M else
     (if c =  "A" then input inStream (~1::ob) s v g ((N,i)::a) N (i+1) M else
       (if c = "W" then input inStream (1::ob) s (N, i) g a N (i+1) M else
         (if c = "S" then input inStream (~2::ob) (N,i) v g a N (i+1) M else
           (if c = "T" then input inStream (0::ob) s v (N,i) a N (i+1) M else
             (if c = "\n" then input inStream ob s v g a (N+1) 0 i else
               (ob, s, v, g, a, N, i, M)))))))
end

fun stayhome_aux obstacles sotiris virus airports goal N M =
let
  val result = Array.array(1, ["R"])
  val l = Array.array(1, 0)
  val size = N*M
  val obst = Array.array(N*M, 0)
  val parent = Array.array(N*M, ~1)
  val v = Queue.mkQueue() : (int * int * int) Queue.queue
  val s = Queue.mkQueue() : (int * int) Queue.queue
  val (x_v, y_v) = virus
  val (x_s, y_s) = sotiris

  fun make_o _ [] = ()
    | make_o i (a::t) = (Array.update(obst, i, a); (make_o (i+1) t)) 

  fun locate x y = x*M + y
  fun exists x y = (x >= 0 andalso x < N andalso y >= 0 andalso y < M)

  fun take_off x y =
  let
    fun aux (xi,yi) =
      if ((x,y) <> (xi,yi)) then 
        (Queue.enqueue(v, (xi, yi, 7)); ()) else ()
  in
    map aux airports; ()
  end  

  fun spread 0 = ()
    | spread num =
    let
      val (x,y, count) = Queue.dequeue(v)
      val i = (locate x y)

      fun spread_aux x y =
      let
        val i_next = (locate x y)
      in
        if ((exists x y) andalso (Array.sub(obst, i_next) <= 0)) then
          ((if ((Array.sub(obst, i_next) = ~1) orelse (Array.sub(obst, i_next) = ~3))  
          then (take_off x y; ()) else ());
          Array.update(obst, i_next, 1);
          Queue.enqueue(v, (x,y,2))) else ()
      end

    in
      if count = 3 then Array.update(obst, i, 1) else ();
      if count = 1 then 
        (spread_aux (x+1) y;
         spread_aux x (y-1);
         spread_aux x (y+1);
         spread_aux (x-1) y)
      else Queue.enqueue(v, (x, y, count-1));
      spread (num-1)
    end

  fun move 0 = ()
    | move num =
    let
      val (x,y) = Queue.dequeue(s)
      val i = (locate x y)
      
      fun move_aux x y =
      let
        val i_next = (locate x y)
      in
        if ((exists x y) andalso 
        (Array.sub(obst, i_next) = 0 orelse Array.sub(obst, i_next) = ~1)) then
          (Array.update(parent, i_next, i); 
          Array.update(obst, i_next, Array.sub(obst, i_next)-2); 
          Queue.enqueue(s, (x, y)); ()) else ()
      end
    
    in
        ((move_aux (x+1) y);
        (move_aux x (y-1));
        (move_aux x (y+1));
        (move_aux (x-1) y);
        move (num-1))
    end

  val (x_end, y_end) = goal
  val finish = locate x_end y_end
  val start = locate x_s y_s 
 
  fun loop 0 = ()
    | loop num = 
    let
      val lv = Queue.length(v)
      val ls = Queue.length(s)
    in
      if (Array.sub(obst, finish) <> 0 orelse ls = 0) 
      then loop 0 else (spread lv; move ls; loop num)
    end

  fun path current = 
  let
    val prev = Array.sub(parent, current)
  in
    if current = start then [] else
     ( Array.update(l, 0, Array.sub(l, 0) + 1);
     if current = prev + 1 then ("R"::(path prev)) else
       (if current = prev - 1 then ("L"::(path prev)) else
         (if current = prev + M then ("D"::(path prev)) else
           (if current = prev - M then ("U"::(path prev)) else []))))
  end

in
  (
   Queue.enqueue(v, (x_v, y_v, 2));
   Queue.enqueue(s, (x_s, y_s));
   make_o 0 obstacles;
   loop 1;
   if (Array.sub(obst, finish) < 0) then
   (Array.update(result, 0, (rev (path finish)));
   print(Int.toString(Array.sub(l, 0)));
   print("\n");
   prnt(Array.sub(result, 0)))
   else print("IMPOSSIBLE\n")
  )
end




fun stayhome file =
let
  val inStream = TextIO.openIn file
  val (obstacles,sotiris,virus,goal,airports,N,i,M) = 
    (input inStream [] (0,0) (0,0) (0,0) [] 0 0 0)
in
  stayhome_aux (rev obstacles) sotiris virus airports goal N M
end
