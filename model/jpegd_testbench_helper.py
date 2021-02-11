from PIL import Image
import matplotlib.pyplot as plt
import sys

from os import path


def preprocess(jpgname, memname):
    print(f"Preprocessing {jpgname} -> {memname}")
    
    fp = open(jpgname, 'rb')
    imbytes = bytearray(fp.read())
    fp.close()
    
    while len(imbytes) % 4 != 0:
        imbytes.append(0)
    
    fout = open(memname, 'w+')
    for i in range(0, len(imbytes), 4):
        line = imbytes[i] + (imbytes[i+1] << 8) + (imbytes[i+2] << 16) + (imbytes[i+3] << 24)
        fout.write(f"{line:08x}\n")
    fout.close()


def showdat(jpgname, datname):
    print(f"Showing {jpgname} and {datname}")
    fp = open(datname, 'r')
    width = int(fp.readline())
    height = int(fp.readline())

    imout = Image.new('RGB', (width, height))

    pixline = fp.readlines()
    pixval = [(int(l[0:2], 16), int(l[2:4], 16), int(l[4:6], 16)) for l in pixline]
    imout.putdata(pixval)
    fp.close()

    imsrc = Image.open(jpgname)

    plt.subplot(121)
    plt.title("Source")
    plt.imshow(imsrc)
    plt.subplot(122)
    plt.title("Decoded")
    plt.imshow(imout)
    plt.show()


operations = ['p', 's']
failstr = """Invalid argument
    Usage: python jpegd_testbench_helper.py p/s jpegname [output mem name / simulation result name]
           python jpegd_testbench_helper.py jpegname
        p: preprocess, convert JPEG into .mem file for testbench to load
        s: show result, show both source JPEG and data from testbench output

    When not specified, by default proprocessing will be selected if output mem file doesn't exist,
    otherwise show result will be selected.
    Will attempt to use the same filename as JPEG file with extension of \".mem\" for preprocessing
    and \".dat\" for showing result."""


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(failstr)
        quit(0)

    if sys.argv[1] == 'p' or sys.argv[1] == 's':
        jpegpath = sys.argv[2]
        if not path.isfile(jpegpath):
            print(f"Error: JPEG file \"{jpegpath}\" not exist")
            quit(0)
            
        if sys.argv[1] == 'p':
            if len(sys.argv) == 4:
                mempath = sys.argv[3]
            else:
                mempath = jpegpath[0:jpegpath.rindex('.')] + '.mem'
            preprocess(jpegpath, mempath)
        else:
            if len(sys.argv) == 4:
                datpath = sys.argv[3]
            else:
                datpath = jpegpath[0:jpegpath.rindex('.')] + '.dat'
            if not path.isfile(datpath):
                print("Error: output file \"{datpath}\" not exist")
                quit(0)
            showdat(jpegpath, datpath)
    else:
        jpegpath = sys.argv[1]
        if not path.isfile(jpegpath):
            print(f"Error: JPEG file \"{jpegpath}\" not exist")
            quit(0)
            
        mempath = jpegpath[0:jpegpath.rindex('.')] + '.mem'
        if path.isfile(mempath):
            datpath = jpegpath[0:jpegpath.rindex('.')] + '.dat'
            if not path.isfile(datpath):
                print("Error: output file \"{datpath}\" not exist")
                quit(0)
            showdat(jpegpath, datpath)
        else:
            preprocess(jpegpath, mempath)
