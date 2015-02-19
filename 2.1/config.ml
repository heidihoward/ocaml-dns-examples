open Mirage

let data = crunch "./data"

let ip_config:ipv4_config = {
  address= Ipaddr.V4.make 192 168 1 2;
  netmask= Ipaddr.V4.make 255 255 255 0;
  gateways= [Ipaddr.V4.make 192 168 1 1];
}

let client =
  foreign "Unikernel.Client" @@ console @-> kv_ro @-> stackv4 @-> job

let () =
  add_to_ocamlfind_libraries [ "dns.mirage"; ];
  register "dns-client" [ client $ default_console $ data $ direct_stackv4_with_static_ipv4 default_console tap0 ip_config]