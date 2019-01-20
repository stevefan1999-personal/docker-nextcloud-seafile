# stevefan1999/docker-nextcloud-seafile

A PoC of running NextCloud and Seafile altogether though the use of SeaDrive

# Configuarion
Use the docker-compose.example.yml as a base and make your own stack

# Known issue
1. File synchronization is off
    - Meaning if you uploaded files from SeaFile, it will not appears in NextCloud 
    - Unless you use WebDAV client to force a probe
2. NextCloud file locks
    - It seems like SeaDrive is not receiving unlinking event in time
    - No workarounds yet
3. No top level writing
    - The architecture of SeaFile (Repository based) doesn't allow it, sorry
    - We have to nest the data folder into one specific repository (nextcloud)