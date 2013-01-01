#!/usr/bin/env python
# -*- coding: utf-8 -*-

import cgi, os, re, sys
print "Content-type: text/html"
print
form = cgi.FieldStorage()

def outputerr(s):
	print '''
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
	<html lang="jp">
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
		<title></title>
	<body>
	%s
	</body>
	</html>
	''' % s
	sys.exit(31)


if "key" not in form:
	print '''
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
	<html lang="jp">
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
		<title></title>
	</body>
	</html>
	<form method="post" action="index.py">
	キー名を入力してください
	<input type="text" name="key"/>
	<input type="submit" value="Go"/>
	<br/>
	注意: ;で区切ることで、複数の値を同時指定できます。
	</form>
	</head>
	<body>
	'''	
else:
	formkeys=form["key"].value
	tmp=re.match('^[-;A-Za-z0-9]+$', formkeys)
	if (tmp==None):
		outputerr('使用できない文字が含まれています。')
		
        keys=formkeys.split(';')
	if (len(keys) > 100):
		outputerr('対象の数が多すぎます。')
	print """
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
	<html lang="jp">
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
		<title></title>
	</head>
	<body>
	"""
	for i in range(len(keys)):
	    print "<h1>", keys[i],"</h1>"
	    os.system('dot -Tpng /tmp/aaa.dot -o %d.png' % i)
	    print '<img src="%d.png" alt="" />' % i
	print """
	</body>
	</html>
	"""
