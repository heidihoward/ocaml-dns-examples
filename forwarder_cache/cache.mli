open Dns
open Dns.Name

type t

(** [create n] a new cache to hold maximum of n resource records *)
val create: int -> t

val lookup: t -> int32 -> domain_name  -> Packet.rr list

val add: t -> int32 -> domain_name -> Packet.rr list -> unit

(** number of resource records (not number of domain names) *)
val size: t -> int

val to_string: t -> string