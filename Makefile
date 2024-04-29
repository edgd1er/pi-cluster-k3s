.PHONY: lint molecule flake8 help all

# Use bash for inline if-statements in arch_patch target
SHELL:=bash

# Enable BuildKit for Docker build
export DOCKER_BUILDKIT:=1

MAKEPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(dir $(MAKEPATH))
CONTAINERS := $(shell docker ps -a -q -f "name=slim4api*")
SONAR_PROP := "sonar-project-local.properties"

help: # help
		#@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m%-10s\033[00m...........%s\n" $$(echo $$l | cut -f 1 -d':') $$(echo $$l | cut -f 2- -d'#'); done
		@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read l; do printf "\033[1;32m%-10s\033[00m...........$${l##*#}\n" $${l%%:*} ; done

all: lint molecule flake8 # all

lint: # check syntax
		@ansible-lint --project-dir $(PWD)
		@ansible-playbook base_config.yml --syntax-check
		@ansible-playbook monit_k3s.yml --syntax-check

molecule: # tests
		@molecule check
		@molecule test

flake8: # lint
		@flake8

poweroff: # shutdown master and nodes
		#ansible cluster -i inventory.yml -m shell -a 'sudo poweroff' -u pi
		@ansible-playbook -i inventory.yml -u pi play_shutdown.yml -u pi --become-user=root -b

update: # update master and nodes
		@ansible cluster -i inventory.yml -m shell -a 'apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get autoremove -y' -u pi --become-user=root -b

reboot: # reboot master and nodes
		@ansible cluster -i inventory.yml -m shell -a 'sudo reboot' -u pi --become-user=root -b

ping:	# ping master and nodes
		@ansible cluster -i inventory.yml -m ping -u pi

common:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t common base_config.yml

msmtpd:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t msmtpd.yml

raspi:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t raspi base_config.yml

sysstat:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t sysstat base_config.yml

nut:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t nut base_config.yml

zram:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t zram base_config.yml

log2ram:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t log2ram base_config.yml

users:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t users base_config.yml

nfs:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t nfs base_config.yml

nfsserver:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t nfsserver base_config.yml

nfsclient:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t nfsclient base_config.yml

ssh:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t ssh base_config.yml

fail2ban:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t fail2ban base_config.yml

firewall:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t firewall base_config.yml

monitoring:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t monitoring monit_k3s.yml

k3s:
		@ansible-playbook -l cluster -i inventory.yml -u pi -t k3s monit_k3s.yml -vv