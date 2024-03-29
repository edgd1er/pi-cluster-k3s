.PHONY: lint molecule flake8 help all

MAKEPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(dir $(MAKEPATH))
CONTAINERS := $(shell docker ps -a -q -f "name=slim4api*")
SONAR_PROP := "sonar-project-local.properties"

help:
		@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# Fichiers/,/^# Base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: lint molecule flake8

lint:
		# yamllint -c .yamllint defaults roles
		ansible-lint --project-dir $(PWD)
		ansible-playbook base_config.yml --syntax-check
		ansible-playbook monit_k3s.yml --syntax-check

molecule:
		molecule check
		molecule test

flake8:
		flake8

poweroff:
		#ansible cluster -i inventory.yml -m shell -a 'sudo poweroff' -u pi
		ansible-playbook -i inventory.yml -u pi play_shutdown.yml

update:
		ansible cluster -i inventory.yml --become-user root -b -u pi -m shell -a ' apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y'

reboot:
		ansible cluster -i inventory.yml --become-user root -b -u pi -m shell -a 'sudo reboot'

ping:
		ansible cluster -i inventory.yml --become-user root -b -u pi -m ping

common:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t common base_config.yml

msmtpd:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t msmtpd.yml

raspi:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t raspi base_config.yml

sysstat:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t sysstat base_config.yml

nut:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t nut base_config.yml

zram:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t zram base_config.yml

log2ram:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t log2ram base_config.yml

users:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t users base_config.yml

nfs:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t nfs base_config.yml

nfsserver:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t nfsserver base_config.yml

nfsclient:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t nfsclient base_config.yml

ssh:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t ssh base_config.yml

fail2ban:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t fail2ban base_config.yml

firewall:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t firewall base_config.yml

monitoring:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t monitoring monit_k3s.yml

k3s:
		ansible-playbook -l cluster -i inventory.yml --become-user root -b -u pi -t k3s monit_k3s.yml -vv