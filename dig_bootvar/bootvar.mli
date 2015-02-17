type t

(* read boot parameter line and store in assoc list - expected format is "key1=val1 key2=val2" *)
val create: unit -> t

(* get boot parameter *)
val get: t -> string -> string option

(* get boot parameter, throws Not Found exception *)
val get_exn: t -> string -> string