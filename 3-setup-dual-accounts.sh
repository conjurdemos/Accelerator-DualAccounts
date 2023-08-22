#!/bin/bash

source ./env-vars.sh
source ./dual-account-params.sh

main() {
  create_safe
  create_accounts
  create_account_rotationalgroup
  add_accounts_to_account_rotationalgroup
  get_accounts
  get_group_info
}

##################################################
# Safe must have a CPM assigned for the subsequent commands to succeed
create_safe() {
  ./cybrvault-cli.sh safe_create $SAFE_NAME "Safe for testing dual accounts" $SAFE_CPM_NAME
  ./cybrvault-cli.sh safe_admin_add $SAFE_NAME $SAFE_ADMIN
}

##################################################
# Create two accounts in the safe, using the appropriate dual-account platform.
create_accounts() {
  ./cybrvault-cli.sh account_create_db_dual $SAFE_NAME $ACCOUNT_PLATFORM_ID \
			$ACCOUNT_NAME1 $ACCOUNT_USER1 $ACCOUNT_PWD1 	\
			$ACCOUNT_ADDRESS $ACCOUNT_DB $ACCOUNT_PORT 	\
			$ACCOUNT_VIRTUALUSERNAME 1 Active
  ./cybrvault-cli.sh account_create_db_dual $SAFE_NAME $ACCOUNT_PLATFORM_ID \
			$ACCOUNT_NAME2 $ACCOUNT_USER2 $ACCOUNT_PWD2 	\
			$ACCOUNT_ADDRESS $ACCOUNT_DB $ACCOUNT_PORT 	\
			$ACCOUNT_VIRTUALUSERNAME 2 Inactive
}

##################################################
# Dumps accounts to ensure they were created correctly
get_accounts() {
  echo "Account $ACCOUNT_NAME1:"
  ./cybrvault-cli.sh account_get $SAFE_NAME $ACCOUNT_NAME1 | jq .
  echo "Account $ACCOUNT_NAME2:"
  ./cybrvault-cli.sh account_get $SAFE_NAME $ACCOUNT_NAME2 | jq .
}

##################################################
# Create an account group for the safe, using the appropriate Rotational Group platform.
create_account_rotationalgroup() {
  ./cybrvault-cli.sh safe_group_create $SAFE_NAME $GROUP_NAME $ROTATIONAL_GROUP_PLATFORM_ID
}

##################################################
# Add the two accounts to the group. Sadly this must be done using the numeric IDs, not their names
add_accounts_to_account_rotationalgroup() {
  printf -v query '.[] | select(.GroupName=="%s").GroupID' $GROUP_NAME
  groupId=$(./cybrvault-cli.sh safe_groups_get $SAFE_NAME | jq -r "$query")

  echo -n "Adding account $ACCOUNT_NAME1 to group $GROUP_NAME..."
  accountId1=$(./cybrvault-cli.sh account_get $SAFE_NAME $ACCOUNT_NAME1 | jq -r .id)
  ./cybrvault-cli.sh safe_group_member_add $groupId $accountId1

  echo -n "Adding account $ACCOUNT_NAME1 to group $GROUP_NAME..."
  accountId2=$(./cybrvault-cli.sh account_get $SAFE_NAME $ACCOUNT_NAME2 | jq -r .id)
  ./cybrvault-cli.sh safe_group_member_add $groupId $accountId2
}

##################################################
# Dumps group and members to ensure it was created correctly
get_group_info() {
  groupJson=$(./cybrvault-cli.sh safe_groups_get $SAFE_NAME)
  echo "Groups in safe $SAFE_NAME:"
  echo $groupJson | jq .
  echo
  printf -v query '.[] | select(.GroupName=="%s").GroupID' $GROUP_NAME
  groupJson=$(./cybrvault-cli.sh safe_groups_get $SAFE_NAME)
  groupId=$(echo $groupJson | jq -r "$query")
  if [[ "$groupId" != "" ]]; then
    echo "Group members:"
    ./cybrvault-cli.sh safe_group_members_get $groupId | jq .
  fi
}

main "$@"
