open Lwt
open V1_LWT
open Dns
open Dns_server

let port = 53
let zonefile = "test.zone"

module Main (C:CONSOLE) (K:KV_RO) (S:STACKV4) = struct

  module U = S.UDPV4
  module DNS = Dns_server_mirage.Make(K)(S)

  let start c k s =
    let t = DNS.create s k in
    DNS.serve_with_zonefile t ~port ~zonefile
end
