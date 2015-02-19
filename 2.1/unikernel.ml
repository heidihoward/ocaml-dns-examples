open Lwt
open V1_LWT
open Printf
open Dns
open Dns_server

let listening_port = 53


module Main (C:CONSOLE) (K:KV_RO) (S:STACKV4) = struct

  module U = S.UDPV4
  module DNS = Dns_server_mirage.Make(K)(S)

  let start c k s =
    let t = DNS.create s k in
    DNS.get_zonebuf t "test.zone"
    >>= (fun zonebuf ->
    DNS.serve_with_zonebuf t ~port:listening_port ~zonebuf)
end
