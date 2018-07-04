#!/bin/bash

# Post installation
# Change password as per your requirement

admpas=ocp1234
userpas=user1234

# Backup config file
cp /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.original

# Get all nodes details

oc get nodes
oc get nodes --show-labels

# Set hosts proper levels

oc label node ose-hub1.mylabsonline.com region="infra" zone="infranodes" --overwrite
oc label node ose-hub2.mylabsonline.com region="infra" zone="infranodes" --overwrite
oc label node ose-node1.mylabsonline.com region="primary" zone="east" --overwrite
oc label node ose-node2.mylabsonline.com region="primary" zone="west" --overwrite
oc label node ose-node3.mylabsonline.com region="primary" zone="south"

# Check all nodes details are updated

oc get nodes
oc get nodes --show-labels

# Edit /etc/origin/master/master-config.yaml and Set defaultNodeSelector like defaultNodeSelector: "region=primary"

#sed -i 's/  defaultNodeSelector: ""/  defaultNodeSelector: "region=primary"/' /etc/origin/master/master-config.yaml

# Set NodeSelector like node-selector: "region=infra" for pod (registry & route) deplyment
# oc patch namespace default -p '{"metadata":{"annotations":{"openshift.io/node-selector":"region=infra"}}}'

# Check it updated properly or not
oc get namespace default -o yaml

# Restart openshift services master

kill -9 `ps -elf | grep open | grep -v grep | awk '{print $4}'`

# Setting Authentication openshift

htpasswd -b -c /etc/origin/master/users.htpasswd admin $admpas
htpasswd -b /etc/origin/master/users.htpasswd pkar $userpas

# Providing admin rights to users (admin & vasu)

oadm policy add-cluster-role-to-user cluster-admin vasu
oadm policy add-cluster-role-to-user cluster-admin admin
oadm policy add-scc-to-user privileged vasu
oadm policy add-scc-to-user privileged admin

# Setting Router for collect metrics only for 3.6

#oc delete dc/router rc/router-1 svc/router 
#oadm router router --replicas=1 --selector='region=infra' --service-account=router --images=openshift/origin-haproxy-router:v3.6.0 --metrics-image='prom/haproxy-exporter:v0.7.1' --expose-metrics 
