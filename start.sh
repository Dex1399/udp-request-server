ip=$(ip addr show eth0 | grep -o 'inet [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+' | cut -d ' ' -f 2)

/root/udpServer -ip=$ip -net=eth0 -mode=system
