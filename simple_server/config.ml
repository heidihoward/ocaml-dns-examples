open Mirage

let data = crunch "./data"

let handler =
  foreign "Unikernel.Main" (console @-> kv_ro @-> stackv4 @-> job)

let ip_config:ipv4_config = {
  address= Ipaddr.V4.make 192 168 1 2;
  netmask= Ipaddr.V4.make 255 255 255 0;
  gateways= [Ipaddr.V4.make 192 168 1 1];
}

let direct =
  let stack = direct_stackv4_with_static_ipv4 default_console tap0 ip_config  in
  handler $ default_console $ data $ stack 

  (* Only add the Unix socket backend if the configuration mode is Unix *)
let socket =
  let c = default_console in
  match get_mode () with
  | `Xen -> []
  | _  -> [ handler $ c $ data $ socket_stackv4 c [Ipaddr.V4.any] ]

let () =
  add_to_ocamlfind_libraries ["dns.mirage";"dns.lwt-core"];
  add_to_opam_packages ["dns"];
  register "dns" (direct :: socket)