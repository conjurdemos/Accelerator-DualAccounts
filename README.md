- Step : Ensure Safe has a CPM assigned
- Step : Export platform
  - export zip file
  - unzip to get .xml & .ini files
- Step : Modify the platform:
  - add VirtualUserName, Index, DualAccountStatus properties to xml file
- Step : Import the modified platform
  - give it a new name
- Step : Create two accounts using modified platform
  - add VirtualUserName key, value: username1/username2
  - add Index key, value: 0/1
  - add DualAccountStatus key, value: Inactive/Active
  - Enable automatic password management

