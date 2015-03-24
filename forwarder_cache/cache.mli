open Dns
open Dns.Name

type time = int32
type t

(** [create n] a new cache to hold maximum of n resource records *)
val create: int -> t

val lookup: t -> time -> domain_name  -> Packet.rr list

val add: t -> time -> domain_name -> Packet.rr list -> unit
val remove: t -> domain_name -> unit

(** compress removes expired RR's, automatically called when there isn't enough space to add
	resource records using the add function *)
val compress: t -> time -> unit

(** number of resource records (not number of domain names) *)
val size: t -> int

val to_string: t -> string