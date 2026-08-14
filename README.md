                                          MAC mobility

VM migration is a very common use case in DC. 
A VM is originally attached on the local interface of a given leaf, and this VM can be migrated to another lead in the DC for a number of reasons when, for example, the hosting hypervisor needs to be stopped for maintenance.

EVPN has a built-in mechanism to detect a VM migration and can quickly update all participating leaf routers of the new situation.
It consists of adding a sequence number to the advertise EVPN RT2 IP-MAC routers.



Topology pre VM migration:

<img width="1338" height="423" alt="image" src="https://github.com/user-attachments/assets/2dea63cd-1496-4daf-86ed-d808efadd5ba" />



Before "migrating" Customer1-100, let´s firt check the current state of the MAC table and BGP Routes, the verification below:


<img width="1316" height="398" alt="image" src="https://github.com/user-attachments/assets/75f81358-3fee-413f-bcfc-18e54bc3e728" />

