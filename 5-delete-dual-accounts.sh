#!/bin/bash

source env-vars.sh
source ./dual-account-params.sh

# DELETE is not supported by account groups. When you delete the
# accounts in an account group, the group is no longer visible as
# a group in the safe, but it is NOT deleted. If you "create" it 
# again with the same name, no error is thrown and the existing group
# is reused. So you must "delete" (remove) the account members before 
# deleting them. That way if the group name is reused, new account 
# members can be added to it.

main() {
  delete_group_members
  ./cybrvault-cli.sh account_delete $SAFE_NAME $ACCOUNT_NAME1
  ./cybrvault-cli.sh account_delete $SAFE_NAME $ACCOUNT_NAME2
  ./cybrvault-cli.sh safe_delete $SAFE_NAME
  echo "Deleted safe $SAFE_NAME."
}

################################
delete_group_members() {
  allSafeGroups=$(./cybrvault-cli.sh safe_groups_get $SAFE_NAME)
  printf -v query '.[] | select(.GroupName=="%s").GroupID' $GROUP_NAME
  groupId=$(echo $allSafeGroups | jq -r "$query")

  echo -n "Removing account $ACCOUNT_NAME1 from group $GROUP_NAME..."
  accountId1=$(./cybrvault-cli.sh account_get $SAFE_NAME $ACCOUNT_NAME1 | jq -r .id)
  ./cybrvault-cli.sh safe_group_member_delete $groupId $accountId1

  echo -n "Removing account $ACCOUNT_NAME2 from group $GROUP_NAME..."
  accountId2=$(./cybrvault-cli.sh account_get $SAFE_NAME $ACCOUNT_NAME2 | jq -r .id)
  ./cybrvault-cli.sh safe_group_member_delete $groupId $accountId2
}

main "$@"
