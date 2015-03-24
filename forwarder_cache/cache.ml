open Dns
open Dns.Name

type time = int32

type t = { 
  max_size: int;
  mutable curr_size: int; 
  data: (domain_name, time * Packet.rr list) Hashtbl.t;
  }

let min_ttl = Int32.of_int 0
let max_ttl = Int32.of_int 2147483647 (* max 1 week, same as dnscache *)

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

let lookup t time query =
  let open Packet in
  match query.questions with
    | [] -> (* QDCOUNT=0 *) None
    | (qu::_) -> (* assume QDCOUNT=1, ignore extra questions *)
  let (init,rrs) = try Hashtbl.find t.data qu.q_name with | Not_found -> (Int32.zero,[]) in
  let check_ttl rr =
    let diff = Int32.sub time init in
    let open Packet in
    if (diff <= rr.ttl) then Some {rr with ttl = Int32.sub rr.ttl diff}
    else None in
  match (map_filter check_ttl rrs) with
    | [] -> None
    | r -> let open Query in
        Some 
        {
        rcode=NoError;
        aa= false;
        answer= r;
        authority= [];
        additional= [];
        }

let filter_rr rr =
  let open Packet in
  match rr.rdata with
    | SOA _ -> false (* do not cache SOA records *)
    | _ -> rr.ttl > min_ttl && rr.ttl < max_ttl

let rec add t time packet =
  let open Packet in
  match packet.questions with
    | [] -> (* QDCOUNT=0 *) ()
    | (qu::_) -> (* assume QDCOUNT=1, ignore extra questions *)
  let name = qu.q_name in
  let rrs = packet.answers in 
  let rrs = List.filter filter_rr rrs in
  let if_no_space () = t.curr_size + List.length rrs > t.max_size in
  if if_no_space() then compress t time;
  if if_no_space() then compress_agressive t time (t.max_size - List.length rrs);
  let length = try 
    Hashtbl.find t.data name
    |> fun (_,xs) -> List.length xs with | Not_found -> 0 in 
  Hashtbl.replace t.data name (time,rrs);
  t.curr_size <- (t.curr_size - length + (List.length rrs))

and compress t time =
  let open Packet in
  let take_action name (init,xs) = 
    match List.filter (fun rr -> (Int32.sub time init) <= rr.ttl) xs with
    | [] -> remove t name
    | rrs -> replace t time name rrs in
  Hashtbl.iter take_action t.data

and remove t name = 
  let length = try 
    Hashtbl.find t.data name
    |> fun (_,xs) -> List.length xs with | Not_found -> 0 in
  Hashtbl.remove t.data name;
  t.curr_size <- t.curr_size - length

and replace t time name rrs = 
  remove t name;
  add t time name rrs

and compress_agressive t _ new_size = 
  (* currently this naively removes RR's, 
  should be replaced with LRU or similar cache eviction policy *)
  Hashtbl.iter (fun k _ -> if new_size<t.curr_size then remove t k) t.data


let size t = t.curr_size

let to_string t = 
  let v_to_string = List.fold_left 
    (fun s rr -> Printf.sprintf "%s %s\n" s (Packet.rr_to_string rr)) "" in
  Hashtbl.fold (fun k (t,v) s -> 
    Printf.sprintf "%s%s %i\n%s" s (domain_name_to_string k) (Int32.to_int t) (v_to_string v))
  t.data (Printf.sprintf "Size [RRs] %i/%i\n" t.curr_size t.max_size)
