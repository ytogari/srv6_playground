#!/bin/bash
# setup multicast routing
install_multicast_routing_daemon() {
    sudo apt install pimd -y
    sudo apt-get install -y smcroute
}


#create namespace
create_bridge(){
    sudo brctl addbr SWR
    sudo brctl addbr SWS
}


create_namespace () {
    sudo ip netns add reciever1
    sudo ip netns add host21
    sudo ip netns add reciever2
    sudo ip netns add host22
    sudo ip netns add reciever3
    sudo ip netns add host23

    sudo ip netns add corenet

    sudo ip netns add sender1
    sudo ip netns add host31
    sudo ip netns add sender2
    sudo ip netns add host32
}


#configure network between reciever and core
connect_reciever1_corenet () {
    sudo ip link add SWR-core type veth peer name core-SWR
    sudo ip link add SWR-reci1 type veth peer name reci1-SWR
    sudo brctl addif SWR SWR-core
    sudo brctl addif SWR SWR-reci1

    sudo ip link set reci1-SWR netns reciever1
    sudo ip link set core-SWR netns corenet

    sudo ip netns exec corenet ip a add 2001:db:2::100/64 dev core-SWR
    sudo ip netns exec corenet ip link set core-SWR up
    sudo ip netns exec corenet ip link set lo up

    sudo ip netns exec reciever1 ip a add 2001:db:2::1/64 dev reci1-SWR
    sudo ip netns exec reciever1 ip link set reci1-SWR up
    sudo ip netns exec reciever1 ip link set lo up

    ## configure underlay routing
    sudo ip netns exec reciever1 ip route add 2001:db:3::/64 via 2001:db:2::100
}
connect_reciever1_host21 () {
    sudo ip link add reci1-host21 type veth peer name host21-reci1
    sudo ip link set reci1-host21 netns reciever1
    sudo ip link set host21-reci1 netns host21

    sudo ip netns exec reciever1 ip a add 2001:db:2:100::1/64 dev reci1-host21
    sudo ip netns exec reciever1 ip link set reci1-host21 up
    sudo ip netns exec reciever1 ip link set lo up

    sudo ip netns exec host21 ip a add 2001:db:2:100::21/64 dev host21-reci1
    sudo ip netns exec host21 ip link set host21-reci1 up
    sudo ip netns exec host21 ip link set lo up

    ## configure SRv6 encap decap setting for reciever1
}


connect_reciever2_corenet () {
    sudo ip link add SWR-reci2 type veth peer name reci2-SWR
    sudo brctl addif SWR SWR-reci2
    sudo ip link set reci2-SWR netns reciever2
    #sudo ip link set core-reci netns corenet

    sudo ip netns exec reciever2 ip a add 2001:db:2::2/64 dev reci2-SWR
    sudo ip netns exec reciever2 ip link set reci2-SWR up
    sudo ip netns exec reciever2 ip link set lo up

    ## configure underlay routing
    sudo ip netns exec reciever2 ip route add 2001:db:3::/64 via 2001:db:2::100
}
connect_reciever2_host22 () {
    sudo ip link add reci2-host22 type veth peer name host22-reci2
    sudo ip link set reci2-host22 netns reciever2
    sudo ip link set host22-reci2 netns host22

    sudo ip netns exec reciever2 ip a add 2001:db:2:200::1/64 dev reci2-host22
    sudo ip netns exec reciever2 ip link set reci2-host22 up
    sudo ip netns exec reciever2 ip link set lo up

    sudo ip netns exec host22 ip a add 2001:db:2:200::22/64 dev host22-reci2
    sudo ip netns exec host22 ip link set host22-reci2 up
    sudo ip netns exec host22 ip link set lo up

    ## configure SRv6 encap decap setting for reciever1
}


connect_reciever3_corenet () {
    sudo ip link add SWR-reci3 type veth peer name reci3-SWR
    sudo brctl addif SWR SWR-reci3
    sudo ip link set reci3-SWR netns reciever3


    sudo ip netns exec reciever3 ip a add 2001:db:2::3/64 dev reci3-SWR
    sudo ip netns exec reciever3 ip link set reci3-SWR up
    sudo ip netns exec reciever3 ip link set lo up

    ## configure underlay routing
    sudo ip netns exec reciever3 ip route add 2001:db:3::/64 via 2001:db:2::100
}
connect_reciever3_host23 () {
    sudo ip link add reci3-host23 type veth peer name host23-reci3
    sudo ip link set reci3-host23 netns reciever3
    sudo ip link set host23-reci3 netns host23

    sudo ip netns exec reciever3 ip a add 2001:db:2:300::1/64 dev reci3-host23
    sudo ip netns exec reciever3 ip link set reci3-host23 up
    sudo ip netns exec reciever3 ip link set lo up

    sudo ip netns exec host23 ip a add 2001:db:2:300::23/64 dev host23-reci3
    sudo ip netns exec host23 ip link set host23-reci3 up
    sudo ip netns exec host23 ip link set lo up

    ## configure SRv6 encap decap setting for reciever1
}


connect_sender1_corenet () {
    sudo ip link add SWS-core type veth peer name core-SWS
    sudo ip link add SWS-send1 type veth peer name send1-SWS
    sudo brctl addif SWS SWS-core
    sudo brctl addif SWS SWS-send1
    
    
    sudo ip link set send1-SWS netns sender1
    sudo ip link set core-SWS netns corenet

    sudo ip netns exec corenet ip a add 2001:db:3::100/64 dev core-SWS
    sudo ip netns exec corenet ip link set core-SWS up
    sudo ip netns exec corenet ip link set lo up

    sudo ip netns exec sender1 ip a add 2001:db:3::1/64 dev send1-SWS
    sudo ip netns exec sender1 ip link set send1-SWS up
    sudo ip netns exec sender1 ip link set lo up

    ## configure underlay routing
    sudo ip netns exec sender1 ip route add 2001:db:2::/64 via 2001:db:3::100
}
connect_sender1_host31 () {
    sudo ip link add send1-host31 type veth peer name host31-send1
    sudo ip link set send1-host31 netns sender1
    sudo ip link set host31-send1 netns host31

    sudo ip netns exec sender1 ip a add 2001:db:3:100::1/64 dev send1-host31
    sudo ip netns exec sender1 ip link set send1-host31 up
    sudo ip netns exec sender1 ip link set lo up

    sudo ip netns exec host31 ip a add 2001:db:3:100::31/64 dev host31-send1
    sudo ip netns exec host31 ip link set host31-send1 up
    sudo ip netns exec host31 ip link set lo up

    ## configure SRv6 encap decap setting for reciever1
}


connect_sender2_corenet () {
    sudo ip link add SWS-send2 type veth peer name send2-SWS
    sudo brctl addif SWS SWS-send2
    sudo ip link set send2-SWS netns sender2


    sudo ip netns exec sender2 ip a add 2001:db:3::2/64 dev send2-SWS
    sudo ip netns exec sender2 ip link set send2-SWS up
    sudo ip netns exec sender2 ip link set lo up

    ## configure underlay routing
    sudo ip netns exec sender2 ip route add 2001:db:2::/64 via 2001:db:3::100
}
connect_sender2_host32 () {
    sudo ip link add send2-host32 type veth peer name host32-send2
    sudo ip link set send2-host32 netns sender2
    sudo ip link set host32-send2 netns host32

    sudo ip netns exec sender2 ip a add 2001:db:3:200::1/64 dev send2-host32
    sudo ip netns exec sender2 ip link set send2-host32 up
    sudo ip netns exec sender2 ip link set lo up

    sudo ip netns exec host32 ip a add 2001:db:3:200::32/64 dev host32-send2
    sudo ip netns exec host32 ip link set host32-send2 up
    sudo ip netns exec host32 ip link set lo up

    ## configure SRv6 encap decap setting for reciever1
}


linkup_bridge() {
    sudo ip link set SWR-core up
    sudo ip link set SWS-core up
    sudo ip link set SWR-reci1 up
    sudo ip link set SWR-reci2 up
    sudo ip link set SWR-reci3 up
    sudo ip link set SWS-send1 up
    sudo ip link set SWS-send2 up
    sudo ip link set SWS up
    sudo ip link set SWR up
}


set_kernel_params(){
    #corenet
    sudo ip netns exec corenet sysctl -w net.ipv6.conf.all.forwarding=1
    sudo ip netns exec corenet sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sudo ip netns exec corenet sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sudo ip netns exec corenet sysctl -w net.ipv6.conf.core-SWS.seg6_enabled=1
    sudo ip netns exec corenet sysctl -w net.ipv6.conf.core-SWR.seg6_enabled=1

    #reciever1
    sudo ip netns exec reciever1 sysctl -w net.ipv6.conf.all.forwarding=1
    sudo ip netns exec reciever1 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sudo ip netns exec reciever1 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sudo ip netns exec reciever1 sysctl -w net.ipv6.conf.reci1-SWR.seg6_enabled=1
    sudo ip netns exec reciever1 sysctl -w net.ipv6.conf.reci1-host21.seg6_enabled=1

    #reciever2
    sudo ip netns exec reciever2 sysctl -w net.ipv6.conf.all.forwarding=1
    sudo ip netns exec reciever2 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sudo ip netns exec reciever2 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sudo ip netns exec reciever2 sysctl -w net.ipv6.conf.reci2-SWR.seg6_enabled=1
    sudo ip netns exec reciever2 sysctl -w net.ipv6.conf.reci2-host22.seg6_enabled=1

    ##reciever3
    sudo ip netns exec reciever3 sysctl -w net.ipv6.conf.all.forwarding=1
    sudo ip netns exec reciever3 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sudo ip netns exec reciever3 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sudo ip netns exec reciever3 sysctl -w net.ipv6.conf.reci3-SWR.seg6_enabled=1
    sudo ip netns exec reciever3 sysctl -w net.ipv6.conf.reci3-host23.seg6_enabled=1

    #sender1
    sudo ip netns exec sender1 sysctl -w net.ipv6.conf.all.forwarding=1
    sudo ip netns exec sender1 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sudo ip netns exec sender1 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sudo ip netns exec sender1 sysctl -w net.ipv6.conf.send1-SWS.seg6_enabled=1
    sudo ip netns exec sender1 sysctl -w net.ipv6.conf.send1-host31.seg6_enabled=1
    
    #sender2
    sudo ip netns exec sender2 sysctl -w net.ipv6.conf.all.forwarding=1
    sudo ip netns exec sender2 sysctl -w net.ipv6.conf.all.seg6_enabled=1
    sudo ip netns exec sender2 sysctl -w net.ipv6.conf.lo.seg6_enabled=1
    sudo ip netns exec sender2 sysctl -w net.ipv6.conf.send2-SWS.seg6_enabled=1
    sudo ip netns exec sender2 sysctl -w net.ipv6.conf.send2-host32.seg6_enabled=1
}


configure_default_route() {
    #for hosts
    sudo ip netns exec host21 ip -6 route add default via 2001:db:2:100::1
    sudo ip netns exec host22 ip -6 route add default via 2001:db:2:200::1
    sudo ip netns exec host23 ip -6 route add default via 2001:db:2:300::1
    sudo ip netns exec host31 ip -6 route add default via 2001:db:3:100::1
    sudo ip netns exec host32 ip -6 route add default via 2001:db:3:200::1
}


configure_srv6_route(){
    #Reciever1
    sudo ip netns exec reciever1 ip -6 route add 2001:db:3:100::/64 encap seg6 mode encap segs 2001:db:3::1 dev reci1-SWR
    sudo ip netns exec reciever1 ip -6 route add 2001:db:3:200::/64 encap seg6 mode encap segs 2001:db:3::2 dev reci1-SWR
    sudo ip netns exec reciever1 ip -6 route add 2001:db:2::1 encap seg6local action End.DX6 nh6 :: dev reci1-SWR

    #Reciever2
    sudo ip netns exec reciever2 ip -6 route add 2001:db:3:100::/64 encap seg6 mode encap segs 2001:db:3::1 dev reci2-SWR
    sudo ip netns exec reciever2 ip -6 route add 2001:db:3:200::/64 encap seg6 mode encap segs 2001:db:3::2 dev reci2-SWR
    sudo ip netns exec reciever2 ip -6 route add 2001:db:2::2 encap seg6local action End.DX6 nh6 :: dev reci2-SWR

    #Reciever3
    sudo ip netns exec reciever3 ip -6 route add 2001:db:3:100::/64 encap seg6 mode encap segs 2001:db:3::1 dev reci3-SWR
    sudo ip netns exec reciever3 ip -6 route add 2001:db:3:200::/64 encap seg6 mode encap segs 2001:db:3::2 dev reci3-SWR
    sudo ip netns exec reciever3 ip -6 route add 2001:db:2::3 encap seg6local action End.DX6 nh6 :: dev reci3-SWR


    #Sender1
    sudo ip netns exec sender1 ip -6 route add 2001:db:2:100::/64 encap seg6 mode encap segs 2001:db:2::1 dev send1-SWS
    sudo ip netns exec sender1 ip -6 route add 2001:db:2:200::/64 encap seg6 mode encap segs 2001:db:2::2 dev send1-SWS
    sudo ip netns exec sender1 ip -6 route add 2001:db:2:300::/64 encap seg6 mode encap segs 2001:db:2::3 dev send1-SWS
    sudo ip netns exec sender1 ip -6 route add 2001:db:3::1 encap seg6local action End.DX6 nh6 :: dev send1-SWS


    #Sender2
    sudo ip netns exec sender2 ip -6 route add 2001:db:2:100::/64 encap seg6 mode encap segs 2001:db:2::1 dev send2-SWS
    sudo ip netns exec sender2 ip -6 route add 2001:db:2:200::/64 encap seg6 mode encap segs 2001:db:2::2 dev send2-SWS
    sudo ip netns exec sender2 ip -6 route add 2001:db:2:300::/64 encap seg6 mode encap segs 2001:db:2::3 dev send2-SWS
    sudo ip netns exec sender2 ip -6 route add 2001:db:3::1 encap seg6local action End.DX6 nh6 :: dev send2-SWS


}


multicast_setting(){
#start daemon in each namespace
sudo ip netns exec reciever1 smcrouted -n -I reciever1 -t 1 &
sudo ip netns exec reciever2 smcrouted -n -I reciever2 -t 2 &
sudo ip netns exec reciever3 smcrouted -n -I reciever3 -t 3 &
sudo ip netns exec corenet smcrouted -n -I corenet -t 4 &
sudo ip netns exec sender1 smcrouted -n -I sender1 -t 5 &
sudo ip netns exec sender2 smcrouted -n -I sender2 -t 6 &

#recievers join multicast group
sudo ip netns exec reciever1 smcroutectl join reci1-SWR ff0e:a::1 -I reciever1
sudo ip netns exec reciever2 smcroutectl join reci2-SWR ff0e:b::1 -I reciever2
sudo ip netns exec reciever3 smcroutectl join reci3-SWR ff0e:a::1 -I reciever3

#configure multicast routing
#corenet


#sender


}


configure_multicast_srv6_route(){
    #sender
    sudo ip netns exec sender1 ip -6 route add 2001:db:2:100::/64 encap seg6 mode encap segs fe0e:a::1 dev send1-SWS

    #reciever
    sudo ip netns exec reciever1 ip -6 route add fe0e:a::1 encap seg6local action End.DX6 nh6 :: dev reci1-SWR
    sudo ip netns exec reciever2 ip -6 route add fe0e:b::1 encap seg6local action End.DX6 nh6 :: dev reci2-SWR
    sudo ip netns exec reciever3 ip -6 route add fe0e:a::1 encap seg6local action End.DX6 nh6 :: dev reci3-SWR
}


reset(){
    sudo ip netns del reciever1
    sudo ip netns del host21
    sudo ip netns del reciever2
    sudo ip netns del host22
    sudo ip netns del reciever3
    sudo ip netns del host23

    sudo ip netns del corenet

    sudo ip netns del sender1
    sudo ip netns del host31
    sudo ip netns del sender2
    sudo ip netns del host32
    sudo ip link set SWS down
    sudo ip link set SWR down
    sudo brctl delbr SWR
    sudo brctl delbr SWS
}

## exec functions
#install_multicast_routing_daemon
create_bridge
create_namespace
connect_reciever1_corenet
connect_reciever1_host21
connect_reciever2_corenet
connect_reciever2_host22
connect_reciever3_corenet
connect_reciever3_host23

connect_sender1_corenet
connect_sender1_host31
connect_sender2_corenet
connect_sender2_host32
linkup_bridge

multicast_setting
configure_srv6_route
configure_default_route
#configure_multicast_srv6_route

set_kernel_params
#reset