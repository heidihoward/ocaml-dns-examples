# ocaml-dns-examples

This is the demo code for a step-by-step guide to setting up your own DNS resolver using MirageOS on Xen/ARM (though the code should work for Xen/x86 and Unix backends too). The tutorial is online:

(Part 1)[http://hh360.user.srcf.net/blog/2015/02/part-1-running-your-own-dns-resolver-with-mirageos]
- 1.1: setting up Xen ARM
- 1.2: how use gethostbyname in ocaml-dns to get the IP corresponding to a hardcoded IP (gethostbyname)[gethostbyname]
- 1.3: adding use of bootvars to part 1.2 (gethostbyname_bootvars)[gethostbyname_bootvars]
- 1.4: how to use resolve in ocaml-dns to get the IP corresponding to a hardcoded IP like a simple version of dig (basic_dig)[basic_dig]

(Part 2)[http://hh360.user.srcf.net/blog/2015/03/part-2-running-your-own-dns-resolver-with-mirageos/]
- 2.1: a simple DNS server, which responses to requests for zones in the zone file (simple_server)[simple_server]

Part 3 - working progress
- 3.1: a simple DNS forwarding resolve, given a DNS query resolve recusively by asking another DNS server
- 3.2: combined DNS server, if zone is in zone file when use simple dns server (2.1), otherwise ask another DNS server (3.1)