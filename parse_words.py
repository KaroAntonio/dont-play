import json

msgs = []

fid = 'assets/words.txt'
f = open(fid, 'r')
msg = ''
for line in f:
	if line.strip() :
		msg += line
	else:
		msgs+=[msg]
		msg = ''

with open('assets/words.json', 'w') as outfile:
	json.dump(msgs, outfile)
