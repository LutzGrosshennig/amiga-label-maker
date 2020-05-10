# amiga-label-maker
A label maker program for 3.5" floppy disks for the Amiga written in 1989 using 100% assembly (Profimat Amiga).

Back in thoose days it was all about floppy disks. Of course the floppies came with some stickers to write down the content of the disk but I wanted to use my shiny new 24 pin printer so I wrote this little utility.
It worked best using some "Zweckform" labels back then. I cant tell if there are still available today.

![Screenshot](https://github.com/LutzGrosshennig/amiga-label-maker/blob/master/screenshots/LabelMaker_Main.jpg)

You can add an image from a selection of images shown here to enhance the overall look of your floppies.

![Screenshot](https://github.com/LutzGrosshennig/amiga-label-maker/blob/master/screenshots/LabelMaker_Images.jpg)

Apperently the programm works still nicely inside WinUAE and even the printing works if you setup the printer emulation (I recommend the EpsonQ 48 dot printer).

I found some code for an enhanced version 2.0 that I may merge at some point in time.

Make sure the data section is moved into chip ram when you assemble the source. 
The original IFF files are included and I used the iff-converter utility to convert them into raw bits.

Have fun with it!
Lutz
