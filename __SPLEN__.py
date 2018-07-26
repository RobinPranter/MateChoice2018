#Modification of the plugin _ISCH_ Made by John Waller.
#Modifications made by Robin Pranter


from ij.gui import WaitForUserDialog, GenericDialog
from ij import IJ, ImagePlus, ImageJ
import math
import os

# ImageJ()


IJ.run("Open...")

imp = IJ.getImage()
title = imp.getWindow()

def distance(x1,y1,x2,y2):
	sq1 = (x1-x2)*(x1-x2)
	sq2 = (y1-y2)*(y1-y2)
	dis = math.sqrt(sq1 + sq2)	
	return(dis)
	
	
while True:
	
    checkbox = False
    while checkbox == False:
        gd = GenericDialog("Title here") 
        gd.addStringField("id", "")
        gd.addCheckbox("Same Image", True)
        gd.showDialog()
        checkbox = gd.getNextBoolean()
        id = gd.getNextString()
        if checkbox == False:
            IJ.run("Open Next")
        else:
            break
	
	
    imp = IJ.getImage() 
    IJ.setTool("multipoint") 
    WaitForUserDialog("make 11 points").show()

    proi = imp.getRoi()
    p = proi.getPolygon() 
    xpts = p.xpoints
    ypts = p.ypoints

    xpts.insert(0, 1111) # inserts a dummy variables so that numbers makes sense
    ypts.insert(0, 1111)
	 
    thorax_width = distance(xpts[2],ypts[2],xpts[3],ypts[3])
    total_body_length = distance(xpts[1],ypts[1],xpts[5],ypts[5])
    abdomen_length = distance(xpts[1],ypts[1],xpts[4],ypts[4])
    abdomen_width = distance(xpts[6],ypts[6],xpts[7],ypts[7])
    forewing_length = distance(xpts[8],ypts[8],xpts[9],ypts[9])
    patch_length = distance(xpts[10],ypts[10],xpts[11],ypts[11])

    print thorax_width

	# path = os.path.join(os.path.expanduser('~'), 'Desktop')
	# directory = path + "\\isch measurements"
	# print path
	# print directory
	# if not os.path.exists(directory):
	 # os.makedirs(directory)
	
	# print os.path.exists(directory) 
	
	# os.chdir(directory)
	# filename = "isch_measurements.txt"
	
    filename = "D:\Documents\MatechoiceColor2018\MorphologyPhotos\measurements.txt"
    print filename
	# filename = "isch_measures.txt"

    try:
        open(filename)
    except IOError:
        myfile = open(filename, "a")
        # myfile.write("header")
        myfile.write(
        "id" + "\t" +
        "thorax_width" + "\t" + 
        "total_body_length" + "\t" + 
        "abdomen_length"  + "\t" +
        "abdomen_width"  + "\t" +
        "forewing_length" + "\t" +
        "patch_length"
        )
        myfile.close()
	
    print id
    myfile = open(filename, "a")
    myfile.write(
    "\n" +
    str(id) + "\t" + 
    str(thorax_width) + "\t" + 
    str(total_body_length) + "\t" + 
    str(abdomen_length)  + "\t" +
    str(abdomen_width)  + "\t" +
    str(forewing_length) + "\t" +
    str(patch_length)
    )
    myfile.close()
    IJ.run("Select None")
