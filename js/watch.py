import subprocess
from time import sleep
from subprocess import Popen, PIPE

log = {}

def removed_watching(fid):
	# check if file contains a line where 'removed' is in the line
	f = open(fid,'r')
	for line in f:
		t = line
		if t not in log:
			log[t] = line
			print(line)
		if 'removed' in line.split():
			f.close()
			return True
	f.close()
	return False

fid = '_watch_out.txt'
process = Popen('echo "" > '+fid, shell=True) 
process = Popen("coffee -cw *.coffee > "+fid, shell=True) 
sleep(0.5)

while True:
	if removed_watching(fid):
		print('-'*10 + 'REWATCHING' + '-'*10)
		process = Popen("rm "+fid+
				'; echo "" > '+fid+
				"; coffee -cw *.coffee > "+fid, shell=True) 
		sleep(0.5)

process = Popen("rm "+fid, shell=True) 
