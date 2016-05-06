# Change Log

## [v1.3.2](https://github.com/chef/knife-openstack/tree/v1.3.2) (2015-10-07)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.3.2.rc1...v1.3.2)

## [v1.3.2.rc1](https://github.com/chef/knife-openstack/tree/v1.3.2.rc1) (2015-10-01)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.3.2.pre.1...v1.3.2.rc1)

**Fixed bugs:**

- knife-openstack server list [\#175](https://github.com/chef/knife-openstack/issues/175)

**Merged pull requests:**

- Support all Fog OpenStack options [\#179](https://github.com/chef/knife-openstack/pull/179) ([BobbyRyterski](https://github.com/BobbyRyterski))

## [v1.3.2.pre.1](https://github.com/chef/knife-openstack/tree/v1.3.2.pre.1) (2015-09-15)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.3.2.pre...v1.3.2.pre.1)

**Closed issues:**

-  uninitialized constant Chef::Knife::Cloud::Command \(NameError\) [\#172](https://github.com/chef/knife-openstack/issues/172)

**Merged pull requests:**

- Fixed ip addresses not visible issue [\#178](https://github.com/chef/knife-openstack/pull/178) ([Vasu1105](https://github.com/Vasu1105))
- 1.3.2.pre release. [\#176](https://github.com/chef/knife-openstack/pull/176) ([jjasghar](https://github.com/jjasghar))

## [v1.3.2.pre](https://github.com/chef/knife-openstack/tree/v1.3.2.pre) (2015-09-04)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.3.1...v1.3.2.pre)

**Merged pull requests:**

- Fix cloud command class loading [\#174](https://github.com/chef/knife-openstack/pull/174) ([Cluster444](https://github.com/Cluster444))

## [v1.3.1](https://github.com/chef/knife-openstack/tree/v1.3.1) (2015-07-18)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.3.0...v1.3.1)

## [v1.3.0](https://github.com/chef/knife-openstack/tree/v1.3.0) (2015-07-18)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.3.0.rc.0...v1.3.0)

**Implemented enhancements:**

- knife openstack floatip \<args\> ? [\#138](https://github.com/chef/knife-openstack/issues/138)

**Merged pull requests:**

- Set the openstack ohai hint when creating a server [\#171](https://github.com/chef/knife-openstack/pull/171) ([mtougeron](https://github.com/mtougeron))
- Vj/adding floating ip commands [\#170](https://github.com/chef/knife-openstack/pull/170) ([Vasu1105](https://github.com/Vasu1105))

## [v1.3.0.rc.0](https://github.com/chef/knife-openstack/tree/v1.3.0.rc.0) (2015-06-25)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.2.0...v1.3.0.rc.0)

**Closed issues:**

- Not finding Private IP During Bootstrap [\#146](https://github.com/chef/knife-openstack/issues/146)

**Merged pull requests:**

- Support --format option [\#166](https://github.com/chef/knife-openstack/pull/166) ([NimishaS](https://github.com/NimishaS))

## [v1.2.0](https://github.com/chef/knife-openstack/tree/v1.2.0) (2015-06-18)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.2.0.rc2...v1.2.0)

**Closed issues:**

- both -F json ad --format json does not work [\#160](https://github.com/chef/knife-openstack/issues/160)

**Merged pull requests:**

- 1.2.0 [\#165](https://github.com/chef/knife-openstack/pull/165) ([jjasghar](https://github.com/jjasghar))

## [v1.2.0.rc2](https://github.com/chef/knife-openstack/tree/v1.2.0.rc2) (2015-06-10)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.2.0.rc1...v1.2.0.rc2)

**Closed issues:**

- Should support bootstrap-template option [\#161](https://github.com/chef/knife-openstack/issues/161)

## [v1.2.0.rc1](https://github.com/chef/knife-openstack/tree/v1.2.0.rc1) (2015-06-04)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v1.1.0...v1.2.0.rc1)

**Implemented enhancements:**

- Vol sched 1.0.0work [\#142](https://github.com/chef/knife-openstack/pull/142) ([karcaw](https://github.com/karcaw))

**Closed issues:**

- Serious Bug with server show instance-id [\#164](https://github.com/chef/knife-openstack/issues/164)
- openstack server create not working with floating ips [\#162](https://github.com/chef/knife-openstack/issues/162)
- handle\_excon\_exception: undefined method [\#153](https://github.com/chef/knife-openstack/issues/153)
- support multi region for OpenStack [\#152](https://github.com/chef/knife-openstack/issues/152)
- knife openstack fails to bootstrap server [\#151](https://github.com/chef/knife-openstack/issues/151)
- Dont see ip addresses with knife openstack server list [\#150](https://github.com/chef/knife-openstack/issues/150)
- Get ERROR: You have either requested an invalid floating IP address or none are available. [\#149](https://github.com/chef/knife-openstack/issues/149)
- Unable to create server w/ v1.0 [\#147](https://github.com/chef/knife-openstack/issues/147)
- no support for multi-region - major blocker [\#139](https://github.com/chef/knife-openstack/issues/139)
- knife.rb proxy settings not honored [\#137](https://github.com/chef/knife-openstack/issues/137)
- Add support for authentication with domain id and name? [\#134](https://github.com/chef/knife-openstack/issues/134)

**Merged pull requests:**

- Allow users to specify alternate private networks. [\#163](https://github.com/chef/knife-openstack/pull/163) ([elbandito](https://github.com/elbandito))

## [v1.1.0](https://github.com/chef/knife-openstack/tree/v1.1.0) (2015-03-06)
[Full Changelog](https://github.com/chef/knife-openstack/compare/1.0.0...v1.1.0)

**Implemented enhancements:**

- Add ability to specify host when using the -Z flag to specify availability-zone [\#158](https://github.com/chef/knife-openstack/issues/158)
- support multi region. [\#148](https://github.com/chef/knife-openstack/pull/148) ([jedipunkz](https://github.com/jedipunkz))

**Merged pull requests:**

- 1.1.0 release branch [\#159](https://github.com/chef/knife-openstack/pull/159) ([jjasghar](https://github.com/jjasghar))
- Update email addresses and copyright date [\#157](https://github.com/chef/knife-openstack/pull/157) ([nathenharvey](https://github.com/nathenharvey))
- remove deprecated 1.9 support and add 2.2.0 [\#156](https://github.com/chef/knife-openstack/pull/156) ([cmluciano](https://github.com/cmluciano))
- Fix rspec tests for travis CI [\#155](https://github.com/chef/knife-openstack/pull/155) ([PierreRambaud](https://github.com/PierreRambaud))
- Fix travis badge [\#154](https://github.com/chef/knife-openstack/pull/154) ([PierreRambaud](https://github.com/PierreRambaud))

## [1.0.0](https://github.com/chef/knife-openstack/tree/1.0.0) (2014-10-07)
[Full Changelog](https://github.com/chef/knife-openstack/compare/1.0.0.rc2...1.0.0)

## [1.0.0.rc2](https://github.com/chef/knife-openstack/tree/1.0.0.rc2) (2014-09-29)
[Full Changelog](https://github.com/chef/knife-openstack/compare/1.0.0.rc1...1.0.0.rc2)

**Closed issues:**

- 1.0.0.rc1 does not grab port id properly.. [\#143](https://github.com/chef/knife-openstack/issues/143)

**Merged pull requests:**

- Updated Gemfile to the released knife-cloud gem [\#145](https://github.com/chef/knife-openstack/pull/145) ([jjasghar](https://github.com/jjasghar))
- find the port id in a better manner [\#144](https://github.com/chef/knife-openstack/pull/144) ([karcaw](https://github.com/karcaw))

## [1.0.0.rc1](https://github.com/chef/knife-openstack/tree/1.0.0.rc1) (2014-09-24)
[Full Changelog](https://github.com/chef/knife-openstack/compare/0.10.0...1.0.0.rc1)

**Merged pull requests:**

- Fixes Associate IPs for neutron [\#141](https://github.com/chef/knife-openstack/pull/141) ([jjasghar](https://github.com/jjasghar))
- \[knife-cloud\] Add Fog dependency  [\#136](https://github.com/chef/knife-openstack/pull/136) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] Update integration tests for post connection validation [\#128](https://github.com/chef/knife-openstack/pull/128) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] Implement changes for post connection validation [\#127](https://github.com/chef/knife-openstack/pull/127) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] Integration tests for metadata,network-ids,delete server\_by\_name and availability-zone option [\#126](https://github.com/chef/knife-openstack/pull/126) ([siddheshwar-more](https://github.com/siddheshwar-more))
- --no-network bug fixed [\#125](https://github.com/chef/knife-openstack/pull/125) ([prabhu-das](https://github.com/prabhu-das))
- \[knife-openstack\] Fix rspec deprecation warnings [\#124](https://github.com/chef/knife-openstack/pull/124) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] Refactor rspec tests [\#122](https://github.com/chef/knife-openstack/pull/122) ([prabhu-das](https://github.com/prabhu-das))
- \[knife-cloud\] Fix rspec deprecation warnings [\#121](https://github.com/chef/knife-openstack/pull/121) ([ameyavarade](https://github.com/ameyavarade))
- Specify name or id for image and flavor in server create [\#120](https://github.com/chef/knife-openstack/pull/120) ([kaustubh-d](https://github.com/kaustubh-d))
- \[knife-cloud\] Updated Integration tests [\#119](https://github.com/chef/knife-openstack/pull/119) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] KNIFE-478: Add ability to bootstrap with SSH passwords [\#118](https://github.com/chef/knife-openstack/pull/118) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] Added coverage for --bootstrap-network, --private-network and --no-network [\#117](https://github.com/chef/knife-openstack/pull/117) ([ameyavarade](https://github.com/ameyavarade))
- \[knife-cloud\] Readme cleanup and Chef rebranding  [\#116](https://github.com/chef/knife-openstack/pull/116) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Added network id option to server create command [\#114](https://github.com/chef/knife-openstack/pull/114) ([prabhu-das](https://github.com/prabhu-das))
- KNIFE-494 add options for secret and secret\_file to support encrypted data bags [\#113](https://github.com/chef/knife-openstack/pull/113) ([jvervlied](https://github.com/jvervlied))
- Sorting list output by name field [\#112](https://github.com/chef/knife-openstack/pull/112) ([prabhu-das](https://github.com/prabhu-das))
- \[knife-cloud\] KNIFE-477: Delete server by name if instance\_id isn't found [\#111](https://github.com/chef/knife-openstack/pull/111) ([ameyavarade](https://github.com/ameyavarade))
- Network list implementation [\#110](https://github.com/chef/knife-openstack/pull/110) ([prabhu-das](https://github.com/prabhu-das))
- \[knife-cloud\] KNIFE-368 Ability to specify metadata during OpenStack server create [\#109](https://github.com/chef/knife-openstack/pull/109) ([ameyavarade](https://github.com/ameyavarade))
- \[knife-cloud\] KNIFE-428 Basic availability zones support [\#108](https://github.com/chef/knife-openstack/pull/108) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] KNIFE-474 knife openstack group list throws a fog deprecation warning [\#107](https://github.com/chef/knife-openstack/pull/107) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[knife-cloud\] KNIFE-467 --no-network fails to find first network IP address  [\#106](https://github.com/chef/knife-openstack/pull/106) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Excon exception spec fix, code change related to knife-cloud. [\#105](https://github.com/chef/knife-openstack/pull/105) ([prabhu-das](https://github.com/prabhu-das))
- README: Clarify misleading knife.rb snippet [\#104](https://github.com/chef/knife-openstack/pull/104) ([srenatus](https://github.com/srenatus))

## [0.10.0](https://github.com/chef/knife-openstack/tree/0.10.0) (2014-05-09)
[Full Changelog](https://github.com/chef/knife-openstack/compare/0.9.1...0.10.0)

**Merged pull requests:**

- KNIFE-478: Add ability to bootstrap with SSH passwords [\#101](https://github.com/chef/knife-openstack/pull/101) ([jmccann](https://github.com/jmccann))
- Fixed broken tests and removed unwanted gem dependency. [\#100](https://github.com/chef/knife-openstack/pull/100) ([prabhu-das](https://github.com/prabhu-das))
- oc 11567 --no-network option [\#97](https://github.com/chef/knife-openstack/pull/97) ([prabhu-das](https://github.com/prabhu-das))
- OC-11566 Update Company name from Opscode, Inc. to Chef Software Inc. [\#95](https://github.com/chef/knife-openstack/pull/95) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-11565  Add support for parameter --user-data during server create for knife-cloud [\#94](https://github.com/chef/knife-openstack/pull/94) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-11564 Update Openstack: Add bootstrap\_network option support [\#93](https://github.com/chef/knife-openstack/pull/93) ([ameyavarade](https://github.com/ameyavarade))
- OC-11563 Add support for setting OpenStack endpoint type for Knife-Cloud [\#92](https://github.com/chef/knife-openstack/pull/92) ([siddheshwar-more](https://github.com/siddheshwar-more))
- \[KNIFE-423\] Add new command 'knife openstack network list', add option --network-ids... [\#78](https://github.com/chef/knife-openstack/pull/78) ([jvervlied](https://github.com/jvervlied))
- Unit test for custom\_arguments passed. [\#77](https://github.com/chef/knife-openstack/pull/77) ([prabhu-das](https://github.com/prabhu-das))
- OC-10525 knife-cloud integration test cleanup Jenkins job Edit [\#76](https://github.com/chef/knife-openstack/pull/76) ([siddheshwar-more](https://github.com/siddheshwar-more))

## [0.9.1](https://github.com/chef/knife-openstack/tree/0.9.1) (2014-03-12)
[Full Changelog](https://github.com/chef/knife-openstack/compare/0.9.0...0.9.1)

## [0.9.0](https://github.com/chef/knife-openstack/tree/0.9.0) (2014-03-07)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.8.1...0.9.0)

**Merged pull requests:**

- KNIFE-395: Add support for setting service endpoint type [\#87](https://github.com/chef/knife-openstack/pull/87) ([adamedx](https://github.com/adamedx))
- OC-11204 - Exception handling and abstraction [\#84](https://github.com/chef/knife-openstack/pull/84) ([kaustubh-d](https://github.com/kaustubh-d))
- \[KNIFE-435\] Added parameter --user-data for cloud-init payload [\#82](https://github.com/chef/knife-openstack/pull/82) ([thielena](https://github.com/thielena))
- OC-10924 Fixed private\_network field not renamed correctly in knife-openstack refactored code [\#81](https://github.com/chef/knife-openstack/pull/81) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC 10878 openstack test fix for knife-cloud change. [\#79](https://github.com/chef/knife-openstack/pull/79) ([prabhu-das](https://github.com/prabhu-das))
- OC-10521 knife-cloud: knife openstack should support summary display during create and new command  [\#74](https://github.com/chef/knife-openstack/pull/74) ([ameyavarade](https://github.com/ameyavarade))
- OC-10520 Knife-cloud should add data summary methods [\#73](https://github.com/chef/knife-openstack/pull/73) ([ameyavarade](https://github.com/ameyavarade))
- \[KNIFE-395\] Add support for setting OpenStack endpoint type [\#72](https://github.com/chef/knife-openstack/pull/72) ([DavidWittman](https://github.com/DavidWittman))
- KNIFE-382 :addssupport for --json-attributes to knife-openstack [\#71](https://github.com/chef/knife-openstack/pull/71) ([adamedx](https://github.com/adamedx))
- OC-9451: knife-openstack throws error on server list when server is in invalid nw state [\#68](https://github.com/chef/knife-openstack/pull/68) ([adamedx](https://github.com/adamedx))
- OC-9430: Knife cloud should support endpoint config and cli option [\#67](https://github.com/chef/knife-openstack/pull/67) ([adamedx](https://github.com/adamedx))
- Oc 9596 Succesfully run the integration tests on jenkins for knife-openstack\(based on knife-cloud\) [\#65](https://github.com/chef/knife-openstack/pull/65) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-9613: os\_image\_type should be inferred from bootstrap protocol if not specified to knife cloud [\#63](https://github.com/chef/knife-openstack/pull/63) ([adamedx](https://github.com/adamedx))
- \[OC-9613\] \[OC-9450\] \[OC-9533\] Sprint88-merged [\#61](https://github.com/chef/knife-openstack/pull/61) ([muktaa](https://github.com/muktaa))
- \[OC-9596\] openstack refactor integration tests [\#58](https://github.com/chef/knife-openstack/pull/58) ([muktaa](https://github.com/muktaa))
- \[OC-9533\] knife CLOUD server list needs to expose Chef data \(node names, attributes\) [\#57](https://github.com/chef/knife-openstack/pull/57) ([siddheshwar-more](https://github.com/siddheshwar-more))
- OC-9390: Handle exit of knife plugin, with correct exit status and from common place in code [\#54](https://github.com/chef/knife-openstack/pull/54) ([adamedx](https://github.com/adamedx))
- OC-9368:  image\_os\_type option should be compulsory in knife-openstack. [\#52](https://github.com/chef/knife-openstack/pull/52) ([adamedx](https://github.com/adamedx))
- OC-9368 Image\_os\_type option should be compulsory in knife-openstack. [\#48](https://github.com/chef/knife-openstack/pull/48) ([siddheshwar-more](https://github.com/siddheshwar-more))
- Sprint 86: Merge Gem dependencies, Travis support [\#46](https://github.com/chef/knife-openstack/pull/46) ([adamedx](https://github.com/adamedx))
- Openstack changes for Sprint86 merged into a common branch [\#44](https://github.com/chef/knife-openstack/pull/44) ([muktaa](https://github.com/muktaa))
- \[KNIFE-382\] Add support for --json-attributes [\#43](https://github.com/chef/knife-openstack/pull/43) ([johnnydtan](https://github.com/johnnydtan))
- Fixing merge issues [\#42](https://github.com/chef/knife-openstack/pull/42) ([muktaa](https://github.com/muktaa))
- OC-9112 update gem dependency [\#41](https://github.com/chef/knife-openstack/pull/41) ([muktaa](https://github.com/muktaa))
- OC-8572: Knife cloud openstack create with bootstrap Windows [\#40](https://github.com/chef/knife-openstack/pull/40) ([adamedx](https://github.com/adamedx))
- OC-8849: Knife-openstack's knife-cloud pointing to git repo of opscode's knife-cl... [\#38](https://github.com/chef/knife-openstack/pull/38) ([adamedx](https://github.com/adamedx))
- OC-8822: Knife cloud openstack server list command [\#37](https://github.com/chef/knife-openstack/pull/37) ([adamedx](https://github.com/adamedx))
- oc-8849 Knife-openstack's knife-cloud pointing to git repo of opscode's knife-cl... [\#35](https://github.com/chef/knife-openstack/pull/35) ([prabhu-das](https://github.com/prabhu-das))
- Resource Listing changes \(OC 8822, 8824, 8825, 8826\) [\#32](https://github.com/chef/knife-openstack/pull/32) ([muktaa](https://github.com/muktaa))
- Refactored knife-openstack code [\#31](https://github.com/chef/knife-openstack/pull/31) ([muktaa](https://github.com/muktaa))

## [v0.8.1](https://github.com/chef/knife-openstack/tree/v0.8.1) (2013-06-14)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.8.0...v0.8.1)

**Merged pull requests:**

- KNIFE-296 and KNIFE-304 fixes [\#28](https://github.com/chef/knife-openstack/pull/28) ([mattray](https://github.com/mattray))

## [v0.8.0](https://github.com/chef/knife-openstack/tree/v0.8.0) (2013-05-13)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.7.1...v0.8.0)

**Merged pull requests:**

- Windows Bootstrapping [\#25](https://github.com/chef/knife-openstack/pull/25) ([chirag-jog](https://github.com/chirag-jog))

## [v0.7.1](https://github.com/chef/knife-openstack/tree/v0.7.1) (2013-04-11)
[Full Changelog](https://github.com/chef/knife-openstack/compare/0.7.0...v0.7.1)

## [0.7.0](https://github.com/chef/knife-openstack/tree/0.7.0) (2013-03-09)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.6.2...0.7.0)

## [v0.6.2](https://github.com/chef/knife-openstack/tree/v0.6.2) (2012-10-14)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.6.0...v0.6.2)

## [v0.6.0](https://github.com/chef/knife-openstack/tree/v0.6.0) (2012-06-27)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.5.4...v0.6.0)

**Closed issues:**

- Fog error on server create [\#5](https://github.com/chef/knife-openstack/issues/5)

**Merged pull requests:**

- Updated chef gem installation instruction after official 0.10.0 release [\#4](https://github.com/chef/knife-openstack/pull/4) ([agoddard](https://github.com/agoddard))

## [v0.5.4](https://github.com/chef/knife-openstack/tree/v0.5.4) (2011-05-03)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.5.3...v0.5.4)

**Merged pull requests:**

- CHEF-2194 Work around nil values returned from openstack [\#3](https://github.com/chef/knife-openstack/pull/3) ([drbrain](https://github.com/drbrain))

## [v0.5.3](https://github.com/chef/knife-openstack/tree/v0.5.3) (2011-04-06)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.5.2...v0.5.3)

## [v0.5.2](https://github.com/chef/knife-openstack/tree/v0.5.2) (2011-04-06)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.5.1...v0.5.2)

**Merged pull requests:**

- Fixes CHEF-2191 [\#1](https://github.com/chef/knife-openstack/pull/1) ([drbrain](https://github.com/drbrain))

## [v0.5.1](https://github.com/chef/knife-openstack/tree/v0.5.1) (2011-04-05)
[Full Changelog](https://github.com/chef/knife-openstack/compare/v0.5.0...v0.5.1)

## [v0.5.0](https://github.com/chef/knife-openstack/tree/v0.5.0) (2011-03-30)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
