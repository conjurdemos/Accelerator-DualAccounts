##########################
# Parameters for Dual Account configuration

# Platform ID for target account
ACCOUNT_PLATFORM_ID=MySQL-DA

# Name of safe that will contain both accounts.
# Will be created if it does not exist.
# If it already exists, ensure it has a CPM assigned to it.
SAFE_NAME=TestDualAccounts

# Name of CPM to assign to safe (required for dual accounts)
SAFE_CPM_NAME=

# Vault user to add to safe with full admin privileges
SAFE_ADMIN=jody.hunt@cyberark.cloud.1741

# Names of dual accounts
ACCOUNT_NAME1=MySQL-DualAccts1
ACCOUNT_NAME2=MySQL-DualAccts2

# Rotational group platform ID 
GROUP_PLATFORM_ID=RotationGroup-Default

# Unique name of group containing above dual accounts
GROUP_NAME=MySQL-AcctGroup

########################## END

