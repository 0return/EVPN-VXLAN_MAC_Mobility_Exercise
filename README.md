                                          MAC mobility

VM migration is a very common use case in DC. 
A VM is originally attached on the local interface of a given leaf, and this VM can be migrated to another lead in the DC for a number of reasons when, for example, the hosting hypervisor needs to be stopped for maintenance.

EVPN has a built-in mechanism to detect a VM migration and can quickly update all participating leaf routers of the new situation.
It consists of adding a sequence number to the advertise EVPN RT2 IP-MAC routers.



Topology pre VM migration:

<img width="1338" height="423" alt="image" src="https://github.com/user-attachments/assets/2dea63cd-1496-4daf-86ed-d808efadd5ba" />



Before "migrating" Customer1-100, let´s firt check the current state of the MAC table and BGP Routes, the verification below:

Leaf1:


<img width="1317" height="404" alt="image" src="https://github.com/user-attachments/assets/3e4e1494-9c90-4289-8565-109e2ef56af6" />



Leaf3:
As expected, leaf3 learns MAC-address of the Customer1-100 is on Leaf2 and MAC-address of the Customer2-100 is on leaf2.


<img width="1530" height="835" alt="image" src="https://github.com/user-attachments/assets/c8f44b7b-45b5-489b-bf42-8898d2776994" />

 
 ** Migrated Customer1-100, from Leaf1 to Leaf2, you can run the following Bash scrip. (Internally, it moves the far-end of the veth pair leaf1:e1-3 → leaf2:e1-5 (down → rename → netns move → rename → up) and triggers a GARP from the client so that leaf2 learns the MAC address immediately. It does not touch the client's eth1 or BGP)
 

<img width="678" height="130" alt="image" src="https://github.com/user-attachments/assets/bcb34a9a-57cc-4742-9d2a-89771c343d03" />

  

Immediately after, check the active EVPN routes on Leaf3 again.

<img width="1541" height="823" alt="image" src="https://github.com/user-attachments/assets/d71419ea-0768-4c52-b0fd-e36b26f54cd6" />


sudo ./migrate.sh leaf2 e1-5 leaf1 e1-3   # moves the MAC back to leaf1 
Each migration increments the sequence number again (1 → 2 → 3…). This is expected and instructive: you can go back and forth several times, watching it rise.


<img width="660" height="122" alt="image" src="https://github.com/user-attachments/assets/736f2fcb-96ca-4737-9725-b901ac83cfb8" />


Leaf3 confirmation.


<img width="1525" height="826" alt="image" src="https://github.com/user-attachments/assets/cd967e5b-cc82-4506-9865-c86253ce6689" />

