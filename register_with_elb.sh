#!/bin/bash

. $(dirname $0)/common_functions.sh

msg "Running AWS CLI with region: $(get_instance_region)"

# get this instance's ID
INSTANCE_ID=$(get_instance_id)
if [ $? != 0 -o -z "$INSTANCE_ID" ]; then
    error_exit "Unable to get this instance's ID; cannot continue."
fi

# Get current time
msg "Started $(basename $0) at $(/bin/date "+%F %T")"
start_sec=$(/bin/date +%s.%N)
ELB_LIST="CG-CodeDeploy-Test-LB"

msg "Checking that user set at least one load balancer"
if test -z "$ELB_LIST"; then
    error_exit "Must have at least one load balancer to register to"
fi

# Loop through all LBs the user set, and attempt to register this instance to them.
for elb in $ELB_LIST; do
    msg "Checking validity of load balancer named '$elb'"
    validate_elb $INSTANCE_ID $elb
    if [ $? != 0 ]; then
        msg "Error validating $elb; cannot continue with this LB"
        continue
    fi

    msg "Registering $INSTANCE_ID to $elb"
    register_instance $INSTANCE_ID $elb

    if [ $? != 0 ]; then
        error_exit "Failed to register instance $INSTANCE_ID from ELB $elb"
    fi
done

# Wait for all Registrations to finish
msg "Waiting for instance to register to its load balancers"
for elb in $ELB_LIST; do
    wait_for_state "elb" $INSTANCE_ID "InService" $elb
    if [ $? != 0 ]; then
        error_exit "Failed waiting for $INSTANCE_ID to return to $elb"
    fi
done

msg "Finished $(basename $0) at $(/bin/date "+%F %T")"

end_sec=$(/bin/date +%s.%N)
elapsed_seconds=$(echo "$end_sec - $start_sec" | /usr/bin/bc)

msg "Elapsed time: $elapsed_seconds"

