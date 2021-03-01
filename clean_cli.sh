#!/bin/bash

export OS_CLOUD=standalone

openstack router remove subnet router subnet-private
openstack router delete router
for fip in $(openstack floating ip list --network network-public -c ID -f value); do openstack floating ip delete $fip ; done
for port in $(openstack port list -c ID -f value) ; do openstack port delete $port ; done
for subnet in $(openstack subnet list -c ID -f value) ; do openstack subnet delete $subnet ; done
for net in $(openstack network list -c ID -f value) ; do openstack network delete $net ; done
