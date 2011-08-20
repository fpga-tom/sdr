CC=gcc -pipe -g -Wall -O2

PREFIX=/usr/local/

#
# FX2 viewer uses GL, GLUT and FFTW 
#
# First two usually come standard, the latter can be obtained from
#              http://www.fftw.org/
#

VIEWER_LIBS= -L/usr/X11/lib -lGL -lGLU -lglut -lfftw3


all: fx2_programmer fx2_viewer test1



test1: fx2_programmer fx2_viewer
	@echo "---------------- FX2 PROGRAMMER -----------------------"
	@./fx2_programmer || true
	@echo "------------------ FX2 VIEWER -------------------------"
	@./fx2_viewer || true


fx2_programmer: fx2_programmer.c
	$(CC) fx2_programmer.c -lusb -o fx2_programmer

fx2_viewer: fx2.c fx2.h viewer.c 
	$(CC) fx2.c viewer.c $(VIEWER_LIBS) -lusb -o fx2_viewer
	

install: fx2_programmer fx2_viewer
	install -s -m 0755 ./fx2_programmer ${PREFIX}/bin/
	install -s -m 0755 ./fx2_viewer ${PREFIX}/bin/

tarball:
	(cd .. ; tar cvf - fx2_programmer/Makefile fx2_programmer/*.c fx2_programmer/*.h fx2_programmer/README.txt) | gzip - > fx2_programmer.tgz
