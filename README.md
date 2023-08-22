# Dual Accounts Accelerator

## Goals:
- Thoroughly document Dual Accounts support in the CyberArk Vault.
- Provide scripts to automate provisioning of Dual Accounts.
- Provide guidance for adding new platforms for Dual Account automation.
- Here is a [detailed explanation for the motivation of Dual Accounts](https://github.com/conjurdemos/Accelerator-DualAccounts#why-are-dual-accounts-necessary).

## Prerequisites
 - A demo host to run the scripts in this repo:
   - a MacOS or Linux VM environment with bash shell support;
   - jq installed;
   - IPV4 network access to the CyberArk PVWA APIs.
 - Make sure all scripts are executable.
   - Run: chmod -R +x *.sh
 - The scripts work with either Privilege Cloud or Self-Hosted PAM:
   - For Privilege Cloud:
     - Admin access to a NON-PRODUCTION Cyberark Identity tenant
     - Admin access to a NON-PRODUCTION CyberArk Privilege Cloud tenant
     - A CyberArk Identity service user & oauth2 confidential client with the Privilege Cloud Admin role.
   - For Self-Hosted PAM:
     - Admin access to a NON-PRODUCTION CyberArk Vault.

![Dual Accounts Object Model](https://github.com/conjurdemos/Accelerator-DualAccounts/blob/main/DualAccountsObjectModel.png?raw=true)

# Dual Accounts Automation

The scripts in this Dual Accounts Accelerator automate tasks required to create Dual Accounts in Self-Hosted or Privilege Cloud vaults. The Accelerator provides out-of-box support for the Platforms in the ./platformlib directory (the “Platform Library”). Support for other Platforms can be added following step 2 below.

### 1) Edit environment variables:
  - env-vars.sh - defines Self-Hosted or Privilege Cloud mode and URLs to their installation. If not already set, it also prompts for the name and password of the CyberArk admin user identity under which to run the scripts.

### 2) Check and update the platform library
 - 0-list-platform-library.sh - lists all platform IDs and system types currently in the platformlib directory. Any platform ID listed can be used to automate dual account creation.
 - 1-export-all-db-platforms.sh - example script showing how to export all platforms of a given system type. As written, the script exports all DB platforms, but can be modified as needed to export platforms of other system types to zipfiles. They can then be unzipped and edited following the [manual configuration steps in Step 2](https://github.com/conjurdemos/Accelerator-DualAccounts#step-2-configure-the-objects-platform-for-dual-account-support) below to implement dual account automation for other platforms.

### 3) Edit dual account parameters:
  - dual-account-params.sh - **Must be edited** to provide specific values for safe, account names, properties, etc.

### 4) Import platforms:
 - 2-import-from-platformlib.sh - imports a specified platform ID into the Vault. Prompts for Platform ID if not provided on the command line. The 0-list-platform-library.sh script lists platform IDs available for importing (see step 1 above).

### 5) Manage dual accounts:
 - 3-setup-dual-accounts.sh - currently only supports creation of database accounts. Automates creation of safe, accounts and account group for a pair of dual accounts specified in dual-account-params.sh.
 - 4-dump-dual-accounts.sh - dumps json records dual accounts specified in dual-account-params.sh.
 - 5-delete-dual-accounts.sh - deletes dual accounts, account group and safe specified in dual-account-params.sh.

## 6) Test Dual Account password rotation:
 - In PVWA, click on one of the two accounts (doesn’t matter which one) and click “Change”
 - Click “Open” and the account will open with the classic UI.
 - Under Account Details, click “Change”, the click “Ok” to trigger immediate password change for the entire group.
 - Monitor the change process clicking Refresh until you see the DualAccountStatus change.
 - Start your timer and when the GracePeriod has elapsed, check to that the Inactive account’s password has changed in the account and target system.
 - Correct any errors and try again.
   - Typical errors are:
     - Incorrect or missing account properties: address, database, port, user
     - Incorrect CPM driver for the target system.
     - Port not open to the CPM’s IP address.<br>
       Note that in Privilege Cloud, the IP address displayed in "System Health->CPM and Accounts Discovery" is a private IP address.

# Manual Dual Accounts Configuration Overview

Dual Accounts are currently documented under the Central Credential Provider:
[Home > Administration > Central Credential Provider > Accounts and Safes > Manage dual accounts](https://docs.cyberark.com/AAM-CP/13.0/en/Content/CP%20and%20ASCP/cv_Managing-Dual-Accounts.htm)
The steps described below map to but deviate somewhat from the manual configuration steps in the documentation to better support automation. But they have the same effect. The [manual configuration steps](https://docs.cyberark.com/AAM-CP/13.0/en/Content/CP%20and%20ASCP/cv_Automatic_dual_account.htm?tocpath=Administration%7CCentral%20Credential%20Provider%7CAccounts%20and%20Safes%7CManage%20dual%20accounts%7C_____1) in the online docs for Self-Hosted PAM also work for Privilege Cloud.

**Step 1: “Configure a rotational group platform”**
A Rotational Group Platform is an Account Group Platform with important differences:
 - Its PlatformType is RotationalGroup
 - It contains an additional password change parameter called GracePeriod
 - It defines additional properties representing the state of individual sets of dual accounts: CurrInd, Index, VirtualUserName, DualAccountStatus
There is no need for more than one Rotational Group Platform unless you want to have groups with different Grace Periods.

**Step 2: “Configure the object’s platform for dual account support”**
This entails modifying a target account platform to add three additional properties: Index, VirtualUserName, DualAccountStatus

**Step3: “Configure accounts and groups for dual account support”**
To see the CPM tab and create groups, the safe must have a CPM assigned to it.
Account groups are not first-class UI objects in PVWA. They do not have their own pages for managing their lifecycle. In PVWA, they only appear in the classic UI on account pages under the CPM tab. 

**Step 4: “Set the index of the group object”**
The documentation calls for using the Private Ark Client to modify the CurrInd value of a group. Fortunately, this step does not appear necessary, given that you cannot use the Private Ark Client with Privilege Cloud.

Below are more detailed instructions for each step above.

## Step 1: “Configure a rotational group platform”
 - Under Groups, activate the Sample Password Group Platform, export it to a local zipfile & unzip to create two files:<br>
Policy-SampleGroup.ini<br>
Policy-SampleGroup.xml<br>
 - Modify the .ini file:
   - Change the PolicyID and PolicyName to something meaningful, e.g. DualAccountsPolicy
   - Change the PolicyType to RotationalGroup (capitalization is significant)
 - Add the following lines at the end of the file, no leading or trailing spaces:<br>
[ADExtraInfo]<br>
[ChangeTask]<br>
[ExtraInfo]<br>
GracePeriod=6<br>

- NOTE: The GracePeriod value represents minutes and can be whatever you want. But pro tip – make the initial value low for testing, then change to a longer duration once rotation is functioning properly.
- Modify the .xml file:
  - Replace \<Optional /\> with the following block:<br>
\<Optional\><br>
\<Property Name=”CurrInd" Type="Numeric" /\><br>
\<Property Name="VirtualUserName" Type="Text"/\><br>
\<Property Name="Index" Type="Numeric"/\><br>
\<Property Name="DualAccountStatus" Type="list" ListValues="Active,Inactive"/\><br>
\</Optional\><br>

 - Add to the platform library and auto-import:
   - Copy the .ini and .xml files into the platformlib directory.
   - Run 0-list-platform-library.sh to ensure it appears in the list.
   - Run 2-import-from-platformlib.sh to import it into the Vault.
 - Manual import:
   - Create a zipfile containing the modified .ini and .xml file and import to your Vault.

  - Verify the new platform appears under Rotational Groups and the Grace Period value is displayed.
  - Click Edit and navigate to:<br>
  Target Account Platform->UI & Workflows->Properties->Optional<br>
  and verify the four properties you added are there.

## Step 2: “Configure the object’s platform for dual account support”
 - Export the the target platform to a local zipfile & unzip to create two files:<br>
Policy-\<base-platform-id\>.ini<br>
Policy-\<base-platform-id\>.xml<br>
 - Modify the .ini file:<br>
   This is the metadata that governs the behavior for any account created for this platform type: password change/verification/reconciliation parameters, drivers, etc. 
   - Modify the PlatformID & PolicyName to something indicative, e.g. MySQL-Dual
 - Modify the .xml file:<br>
   This is the metadata that (among other things) specifies the required and optional properties of an account.
   - Modify the PlatformID to match the one in the .ini file
   - Add the following properties. Making them optional allows using this platform for non-dual account purposes:<br>
\<Property Name="VirtualUserName" Type="Text"/\><br>
\<Property Name="Index" Type="Numeric"/\><br>
\<Property Name="DualAccountStatus" Type="list" ListValues="Active,Inactive"/\><br>

 - Add to the platform library and auto-import:
   - Copy the .ini and .xml files into the platformlib directory.
   - Run 0-list-platform-library.sh to ensure it appears in the list.
   - Run 2-import-from-platformlib.sh to import it into the Vault.
 - Manual import:
   - Create a zipfile containing the modified .ini and .xml file and import to your Vault.

 - Verify the new target platform appears in the appropriate category, e.g. Databases
 - Click Edit and navigate to:<br>
   Target Account Platform->UI & Workflows->Properties->Optional<br>
   and verify the four properties you added are there.

## Step 3: “Configure accounts and groups for dual account support” 
 - Create two accounts that have the PlatformID of the target account platform created in step 2. 
 - The accounts must be in the same safe, and the safe must have a CPM assigned to it.
 - Using the classic UI, you must modify each account in a dual account pair.
 - Open one of the accounts in the PVWA classic UI:
   - Under the CPM tab, click “Create New” a specify a unique account group name for the pair of accounts with the Rotational Group as its platform.
   - Choose a VirtualUserName to represent this pair of accounts.<br>
     The VirtualUserName is effectively the Account Name of the pair of accounts. It appears in Conjur variable names in place of either account name. It is used in CP queries to retrieve the currently active account properties.
   - Set Index property to: 1
   - Set DualAccountStatus property to: Active
 - Open the other account in the PVWA classic UI:
   - Under the CPM tab, click “Modify” and select the group name you created for the first account.
   - Set VirtualUserName to the same name as in the first account
   - Set Index property to: 2
   - Set DualAccountStatus property to: Inactive

## Step 4: Test dual accounts password rotation
 - [See above](https://github.com/conjurdemos/Accelerator-DualAccounts#6-test-dual-account-password-rotation)

## Why are Dual Accounts necessary?

 - Secret rotations are a fundamental security best-practice. But if care is not taken, rotating secrets can lead to application outages. If an application holds onto a secret value, it won’t work once it’s been rotated in the target database, service, server, etc. This could lock the application out of the target system.
 - Applications should always fetch a secret from a secrets management system right before using it. That helps guarantee the application has an up-to-date secret, but it is not sufficient for several reasons:
   - Some applications require continuous connectivity.
   - Some databases will break a connection on password change.
   - Due to syncing and caching in secrets management systems, there can be unavoidable lag time (latency) between the moment the password is changed, and when the new value is available to the application.
 - One method to address this is to coordinate rotations during a precisely timed change window. But most organizations dislike this idea: it’s inconvenient, definitely not foolproof, and some applications can’t be brought down or paused for a change window.
 - A more automated, simple and foolproof solution is Dual Accounts, supported by the CyberArk Vault.
 - Dual Accounts are similar to a DevOps application deployment model call [Blue/Green Deployments](https://www.redhat.com/en/topics/devops/what-is-blue-green-deployment).
 - See [this explainer video](https://youtu.be/i122iZWKVb0) for a thorough explanation and demo of Dual Accounts.


