import glob, re, sys, os, os.path, time, getopt, time
import win32com
import win32com.client

# Where python installed
pythonexecdir=os.path.dirname(sys.executable)

filepath=pythonexecdir + r"\local\win32exceltest.xls" 
inputsheetname=filepath

xapp = win32com.client.Dispatch("Excel.Application")
xapp.Visible = True 
  
book = xapp.Workbooks.Open(inputsheetname)
count = book.WorkSheets.Count
Sheet = book.Worksheets(1)

def sj(ustr):
	return ustr.encode('shift-jis')

c=list()
for i in range(21):
    c.append(range(8))
    for j in c[i]:
        c[i][j]=''
c = Sheet.Range("A1:D20").Value 

#print c

for i in c:
    for j in i:
        if (type(j) == unicode):
            pass
            #print sj(j)
        else:
            pass
            #print sj(repr(j))

# Copy&Paste Cells
# https://sites.google.com/site/pythoncasestudy/home/pywin32kara-comwo-tsuka-tsu-te-excelwo-sousa-suru-houhou
#
Sheet.Range("E5:F10").Copy()

## Check where you copy
##time.sleep(10)
##Sheet.Range("H5:I10").Copy()
##time.sleep(10)

tmp=Sheet.Range("H5").Value
# Don't overwrite cells
if (not None==tmp):
    print "not copied"
    sys.exit(33)
Sheet.Range("H5").Insert()


# Create Template AutoShape
Sheet.Shapes.AddShape(9, 0,0,10,10) #9 for Circle
shape=Sheet.Shapes(1)
# Change Color
# http://www.happy2-island.com/excelsmile/smile03/capter01209.shtml
shape.Line.ForeColor.RGB=0x0000F0
shape.Line.Weight=2
shape.Fill.ForeColor.RGB=0xFFFFFF

# Put this where you wanna put..
shape.Copy()
Sheet.Activate()
Sheet.Range("H5").Activate()
Sheet.Paste()
shape.Delete()




