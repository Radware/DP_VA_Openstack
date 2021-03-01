#/bin/bash

function continue {
	read -p "Do you want to continue? (y/n)" -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Yy]$ ]]
	then
		echo Exiting
		exit 1
	fi
}
echo -e "\nStarting the creation scripts. Creating flavor."
continue

export OS_CLOUD=standalone

# TODO: Create flavor
openstack flavor list
#openstack flavor create --ram 16384 --disk 10 --vcpu 2 --public VDP-2vCPU-16gb-10gb

echo -e "\nCreating the image"
#continue

# TODO: add Image to glance
openstack image list

echo -e "\nCreating the networks"
continue

# Create networks - public (external), private, client(sriov), server(sriov)
openstack network create --provider-physical-network sriovnet1 --provider-network-type vlan --disable-port-security --provider-segment 820 network-sriov-server
openstack network create --provider-physical-network sriovnet2 --provider-network-type vlan --disable-port-security --provider-segment 620 network-sriov-client
openstack network create --provider-network-type geneve --external --provider-segment 82 --disable-port-security network-public
openstack network create --provider-network-type geneve --internal --provider-segment 47 --disable-port-security network-private
netid_server=$(openstack network show network-sriov-server -c id -f value)
netid_client=$(openstack network show network-sriov-client -c id -f value)
openstack network list
sleep 1
echo -e "\nCreating the subnets"
continue

# Create Subnets for the networks
openstack subnet create --subnet-range 192.168.200.0/24 --no-dhcp --gateway 192.168.200.1 --network network-sriov-server subnet-sriov-server
openstack subnet create --subnet-range 192.168.100.0/24 --no-dhcp --gateway 192.168.100.1 --network network-sriov-client subnet-sriov-client
openstack subnet create --subnet-range 10.174.0.0/16 --no-dhcp --gateway 10.174.1.1 --network network-public subnet-public
openstack subnet create --subnet-range 192.168.1.0/24 --no-dhcp --gateway 192.168.1.1 --network network-private subnet-private
openstack subnet list

echo -e "\nCreating the router"
continue

# Create Router for private+public
openstack router create router
openstack router set router --external-gateway network-public
openstack router add subnet router subnet-private
openstack router list

echo -e "\nCreating the floating IP"
continue


# Create Floating IP
openstack floating ip create network-public
openstack floating ip list

echo -e "\nCreating the ports"
continue


# Create ports: mgmt, client-sriov, server-sriov
openstack port create --network $netid_server --vnic-type direct --disable-port-security sriov-port-server
openstack port create --network $netid_client --vnic-type direct --disable-port-security sriov-port-client
port_id_server=$(openstack port show sriov-port-server -c id -f value)
port_id_client=$(openstack port show sriov-port-client -c id -f value)
openstack port list

echo -e "\nCreating the server!"
continue

security_group=$(openstack security group list --project admin -c ID -f value)

# Create the server
#TODO FIX
openstack server create --flavor VDP-2vCPU-16gb-10gb --image cirros --network network-private --nic port-id=$port_id_server --nic port-id=$port_id_client VDP-sriov
#openstack server add floating ip VDP-sriov <floatingip>

openstack server list
