all: jtag
jtag: main.c
	$(CC) -g $< -o $@ `libusb-config --libs`
clean:
	rm jtag
