open Dns
open Dns.Name

type t = { 
  max_size: int;
  mutable curr_size: int; 
  data: (domain_name, (int32 * Packet.rr) list) Hashtbl.t;
  }

let create n = {
  max_size = n;
  curr_size = 0;
  data = Hashtbl.create (n/5);
  }
  
let map_filter ~f xs = 
  let rec apply = function
  | [] -> []
  | x::xs -> 
    match f x with 
    | None -> apply xs 
    | Some y -> y :: (apply xs) in
  apply xs

let lookup t time name = 
  let rrs = try Hashtbl.find t.data name with | Not_found -> [] in
  let check_ttl (init,rr) =
    let diff = Int32.sub time init in
    let open Packet in
    if (diff <= rr.ttl) then Some {rr with ttl = Int32.sub rr.ttl diff}
    else None in
  map_filter check_ttl rrs

let add t time name rrs =
  let length = try List.length (Hashtbl.find t.data name) with | Not_found -> 0 in 
  Hashtbl.replace t.data name (List.map (fun rr -> (time,rr)) rrs);
  t.curr_size <- (t.curr_size - length + (List.length rrs))

let compress t time =
  let open Packet in
  let is_valid (init,rr) = (Int32.sub time init) <= rr.ttl in
  Hashtbl.iter (fun name i -> Hashtbl.replace t.data name (List.filter is_valid i)) t.data

let to_string t = 
  let v_to_string = List.fold_left 
    (fun s (t,rr) -> Printf.sprintf "%s%i %s\n" s (Int32.to_int t) (Packet.rr_to_string rr)) "" in
  Hashtbl.fold (fun k v s -> Printf.sprintf "%s%s\n%s" s (domain_name_to_string k) (v_to_string v))
  t.data (Printf.sprintf "Size [RRs] %i/%i\n" t.curr_size t.max_size)

