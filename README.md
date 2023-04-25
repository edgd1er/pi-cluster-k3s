# pi-cluster-k3s
WIP: Use ansible to provision rpi boards and install k3s

```bash
sudo apt-get install ansible sshpass

```

# local install
```bash

sudo snap install --classic kubectl helm
mkdir -p ~/.kube/
scp root@netpi01:/etc/rancher/k3s/k3s.yaml ~/.kube/config



```

