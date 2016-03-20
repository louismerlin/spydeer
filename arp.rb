def arp_mac_addr()
	arp = `sudo arp-scan -l`
	return arp.split(/\n/).select{|l| l[0]=='1' && l[1]=='9' && l[2]=='2'}.map{|l| l.split(' ')[1]}
end
