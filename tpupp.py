#!/usr/bin/env python
############## Setting
node={} # Don't remove

files=[
"/tmp/bbb", 
"/tmp/bbb1", 
"/tmp/bbb2", 
"/tmp/bbb3"
]
dmfiles=[
"/tmp/dm1",
"/tmp/dm2",
]
node['localhost']=files
node['scfc-virt2.jp.example.org']=files
node['fedora-intel1']=dmfiles
node['fedora-intel1.jp.example.org']=dmfiles

############## Environment

path='/var/tmp/'

############## logic

import cgi,sys,os
print "Content-type: text/html"
print ""


fs=cgi.FieldStorage()
#cgi.print_environ()


if (fs.has_key('hostname')):
  hostname=fs.getvalue('hostname')
  if (node.has_key(hostname)):
    files=node[hostname]
    tmpfilesstr=repr(files)
    sys.stderr.write("nodename:%(hostname)s\nfiles: %(tmpfilesstr)s\n" % (locals()))
  else:
    # Don't Delete "TPUPPWARN:"
    print "TPUPPWARN: No such node.: %s" % hostname
    sys.exit(32)
else:
  print "TPUPPWARN: Give me your hostname, please."
  sys.exit(33)

try:
  ### Obtain file itself
  sys.stderr.write ("obtain file\n")
  if (fs.has_key('filename')):
    filename=fs.getvalue('filename')
    sys.stderr.write ("filename is %(filename)s\n" %locals())
    sys.stderr.write ("filename is %(filename)s\n" %locals())
    if filename in files:
      tmp=file("%s/%s" %(path, filename))
      sys.stdout.write(tmp.read())
      tmp.close()
  ### Obtain all the checksums
  else:
    sys.stderr.write ("obtain checksums for all files\n")
    for f in files:
      ### Check if file is there
      sys.stderr.write("filepath: %(path)s/%(f)s\n" % locals())
      tmp=file("%(path)s/%(f)s" % locals())
      tmp.close()
      ### obtain cksum
      tmp=os.popen("cksum %s%s | sed 's!%s!!'" % (path,f,path))
      sys.stdout.write(tmp.read())
      tmp.close()
except:
  print "TPUPPWARN: Can't retrieve file from puppet server. Check httpd error_log" 
  sys.exit(33)
