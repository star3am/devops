#!/usr/bin/env bash
# this file knock a sequence of ports and opens iptables or aws sec. group if call succeed

PUPPET_MASTER=puppet-master.tld
KNOCK_HOST="${PUPPET_MASTER}"
KNOCK_PORTS="3333 6666 9999"
KNOCK_LOOPS=0
KNOCK_MAX_LOOPS=30

echo BEGIN PUPPET $(date '+%Y-%m-%d %H:%M:%S')

# ensure utf-8 is present
if grep -q "LANG=en_US.UTF-8" /etc/environment > /dev/null 2>&1; then
  echo "LANG present in /etc/environment"
else
  echo "LANG=en_US.UTF-8" >> /etc/environment
fi

if grep -q "LANG=en_US.UTF-8" /etc/default/puppet > /dev/null 2>&1; then
  echo "LANG present in /etc/default/puppet"
else
  echo "export LANG=en_US.UTF-8" >> /etc/default/puppet
fi

export LANG=en_US.UTF-8
export DEBIAN_FRONTEND=noninteractive

# install puppet agent
if ! dpkg -l puppetlabs-release-pc1 > /dev/null; then
  echo "Installing and configuring latest puppet..."
  wget -nv https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb
  sudo dpkg -i puppetlabs-release-pc1-trusty.deb
  # BUG: http://askubuntu.com/questions/41605/trouble-downloading-packages-list-due-to-a-hash-sum-mismatch-error
  sudo apt-get update -q -o Acquire::CompressionTypes::Order::=gz
  sudo apt-get install -qfy puppet-agent curl lynx
  sudo apt-get install -qy --allow-unauthenticated knockd
fi

# knock to gain entry to the puppet port
echo "Knock on $KNOCK_HOST"

/usr/bin/knock $KNOCK_HOST $KNOCK_PORTS -v
/usr/bin/curl -m 5 -I --silent $KNOCK_HOST:8140

while [ $? -ne 52 ] && [ $KNOCK_LOOPS -lt $KNOCK_MAX_LOOPS ]
do
  sleep 1
  ((KNOCK_LOOPS++))
  echo "Knocking ${KNOCK_LOOPS}"
  /usr/bin/knock $KNOCK_HOST $KNOCK_PORTS -v
  /usr/bin/curl -m 5 -I --silent $KNOCK_HOST:8140
done

# run the puppet agent for the first time
echo "Running puppet agent..."

AGENT_LOCK="/opt/puppetlabs/puppet/cache/state/agent_catalog_run.lock"

service puppet stop && pkill -f puppet && if [ -e "$AGENT_LOCK" ]; then rm "$AGENT_LOCK"; fi

/opt/puppetlabs/bin/puppet agent --onetime --no-daemonize --verbose --color false --configtimeout 5m --waitforcert 300 --server $PUPPET_MASTER

echo END PUPPET $(date '+%Y-%m-%d %H:%M:%S')
