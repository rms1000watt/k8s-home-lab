# K8s Home Lab

## Introduction

Build a k8s lab at home. Not production ready...

## References

- https://www.server-world.info/en/note?os=Debian_12&p=kubernetes&f=1

## Steps

- Purchase USB thumb drive
- [Purchase Beelink S12 Mini Pro](https://www.amazon.com/Beelink-Pro-Desktop-Computer-1000Mbps/dp/B0C89TQ1YF)
- Install etcher

```bash
brew install --cask balenaetcher
```

- [Download Debian 12 Server](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso)
- Install Debian 12 Server ISO onto the USB thumb drive using etcher
- Plugin USB to Beelink and power on Beelink
- Press and hold `esc` to enter UEFI
- Select the USB drive as the boot disk
- Save and restart
- Install using graphical view
- When you get to the disk formatting, write over everything
- When you get to software installation, ignore desktop and graphical
- When complete, restart and hold `esc` for UEFI & fix boot order
- Now you can ssh as your user
- Configure the machine for ssh and sudo:

```bash
# Add sudo
su -
apt update
apt install sudo vim

# Add passwordless sudo to bottom of this file
vim /etc/sudoers
# ryan     ALL=(ALL) NOPASSWD:ALL
exit

# Add passwordless ssh to bottom of this file
sudo vim /etc/ssh/sshd_config
# PubkeyAuthentication yes
# AuthorizedKeysFile .ssh/authorized_keys

# Go back to host machine and copy ssh pub key over
exit
ssh-copy-id ryan@k8s1.rms1000watt.com

# Now can passwordless ssh
ssh -i ~/.ssh/id_rsa ryan@k8s1.rms1000watt.com
```

- Now run the `setup-*.sh` files on each of the proper machines
- On local, install kubectl
- On local, get the kubeconfig from the control plane

```bash
cp ~/.kube/config ~/.kube/config.bak
scp -i ~/.ssh/id_rsa ryan@k8s1.rms1000watt.com:/home/ryan/.kube/config ~/.kube/config
```

- Install helm and helmfile and helm-diff
- Do some k8s stuff

```bash
helmfile -f helmfile.d/metrics-server.yaml apply
helmfile -f helmfile.d/ingress-nginx.yaml apply

kubectl create ns prod
env=prod helmfile -f helmfile.d/echo-server.yaml apply

# update /etc/hosts
# 192.168.1.135 echo.rms1000watt.com

curl echo.rms1000watt.com
```

## TODO

- create k8s users
- figure out if there's a better way to handle ingress instead of host network ingress-nginx daemonset
