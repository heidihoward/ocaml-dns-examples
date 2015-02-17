open Lwt
open V1_LWT

let domain = "google.com"
let server = Ipaddr.V4.make 8 8 8 8

module Client (C:CONSOLE) (S:STACKV4) = struct

  module U = S.UDPV4
  module DNS = Dns_resolver_mirage.Make(OS.Time)(S)

  let start c s =
    Bootvar.create () >>= fun bootvar ->
    let domain = Bootvar.get_exn bootvar "domain" in
    let server = Ipaddr.V4.of_string_exn (Bootvar.get_exn bootvar "server") in
    let t = DNS.create s in
    OS.Time.sleep 2.0 
    >>= fun () ->
    C.log_s c ("Resolving " ^ domain)
    >>= fun () ->
    DNS.gethostbyname t ~server domain
    >>= fun rl ->
    Lwt_list.iter_s
      (fun r ->
         C.log_s c ("Answer " ^ (Ipaddr.to_string r))
      ) rl

end