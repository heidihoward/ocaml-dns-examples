open Lwt
open V1_LWT
open Printf
open Dns_server

let listening_port = 5354


module Main (C:CONSOLE) (K:KV_RO) (S:STACKV4) = struct

 module U = S.UDPV4

  let listener ~processor = 
    fun ~src ~dst ~src_port buf ->
          C.log_s c "got udp"
          >>= fun () ->
          let ba = Cstruct.to_bigarray buf in
          let src' = (Ipaddr.V4 dst), listening_port in
          let dst' = (Ipaddr.V4 src), src_port in
          let obuf = (Io_page.get 1 :> Dns.Buf.t) in
          process_query ba (Dns.Buf.length ba) obuf src' dst' processor
          >>= function
          | None ->
            C.log_s c "No response"
          | Some rba ->
            let rbuf = Cstruct.of_bigarray rba in
            U.write ~source_port:listening_port ~dest_ip:src ~dest_port:src_port udp rbuf

  let start c k s =
    lwt zonebuf = 
      K.size k "test.zone"
      >>= function
      | `Error _ -> fail (Failure "test.zone not found")
      | `Ok sz ->
        K.read k "test.zone" 0 (Int64.to_int sz) 
        >>= function 
        | `Error _ -> fail (Failure "test.zone error reading")
        | `Ok pages -> return (String.concat "" (List.map Cstruct.to_string pages))
    in
    let process = process_of_zonebuf zonebuf in
    let processor = (processor_of_process process :> (module PROCESSOR)) in
    S.listen_udpv4 s listening_port (listener ~processor);
    S.listen s
end
