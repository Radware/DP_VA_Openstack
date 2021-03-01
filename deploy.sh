#!/bin/bash


if test -n "$TMUX"
then

	export IP=10.174.60.2
	export NETMASK=16
	export INTERFACE=eno2
	
	TEMPLATES=/home/stack/templates_dan/

	sudo openstack tripleo deploy \
	--templates \
	--local-ip=$IP/$NETMASK \
	-e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
	-e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
	-e $TEMPLATES/standalone-tripleo.yaml \
	-r $TEMPLATES/Standalone.yaml \
	-e $TEMPLATES/containers-prepare-parameters.yaml \
	-e $TEMPLATES/standalone_parameters.yaml \
	-e $TEMPLATES/neutron-ovn-standalone.yaml \
	-e $TEMPLATES/neutron-ovn-sriov.yaml \
	-e $TEMPLATES/mistral.yaml \
	--output-dir $TEMPLATES \
	--standalone
else
	printf "This is NOT a tmux session.\n"
	exit 1
fi
