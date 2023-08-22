##########################
# Parameters for Dual Account configuration

# Platform ID for target account
ACCOUNT_PLATFORM_ID=MySQL-Dual

# Rotational group platform ID 
ROTATIONAL_GROUP_PLATFORM_ID=RotationalGroup-Default

# Unique name of group to be created to contain above dual accounts
GROUP_NAME=MySQL-AcctGroup

# Name of safe that will contain both accounts.
# Will be created if it does not exist.
# If it already exists, ensure it has a CPM assigned to it
# or group creation will fail.
SAFE_NAME=TestDualAccounts

# Name of CPM to assign to safe (required for dual accounts)
SAFE_CPM_NAME=PasswordManager1

# Vault user to add to safe with full admin privileges
SAFE_ADMIN=Admin1

# Common account properties
ACCOUNT_ADDRESS=192.168.1.1
ACCOUNT_DB=petclinic
ACCOUNT_PORT=3306
ACCOUNT_VIRTUALUSERNAME=MySQL-VU

# Account 1 will be initially Active
ACCOUNT_NAME1=MySQL-DualAccts1
ACCOUNT_USER1=testuser1
ACCOUNT_PWD1=Cyberark1

# Account 2 will be initially Inactive
ACCOUNT_NAME2=MySQL-DualAccts2
ACCOUNT_USER2=testuser2
ACCOUNT_PWD2=Cyberark1

########################## END

