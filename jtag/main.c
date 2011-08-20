#include <stdio.h>
#include <usb.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#include "jtag.h"

#define VENDOR_ID 0x1fc9
#define PRODUCT_ID 0x1243


usb_dev_handle* findDev() {
	struct usb_bus *bus;
	struct usb_device *dev;

	for(bus=usb_busses; bus; bus=bus->next) {
		for(dev=bus->devices;dev; dev=dev->next) {
			if (dev->descriptor.idVendor == VENDOR_ID && 
 
                                dev->descriptor.idProduct == PRODUCT_ID ) {
 
                                usb_dev_handle *handle;
 
                                printf("lvr_winusb with Vendor Id: %x and Product Id: %x found.\n", VENDOR_ID, PRODUCT_ID);
 
                                if (!(handle = usb_open(dev))) {
 
                                        printf("Could not open USB device\n");
 
                                        return NULL;
 
                                }
 
                                return handle;

		}
	}
	}

	return NULL;
}

int main(int argc, char** argv) {
	struct stat sb;
	usb_dev_handle *dev;
	jtag_cmd_t jtag;
	uint8_t *xsvf = NULL;
	off_t xsvfSize=0;
	int act;
	int i;

	if(argc < 2) {
		fprintf(stderr, "usage: %s <cmd> [file]\n", argv[0]);
		exit(-1);
	}

	if(!strcmp(argv[1], "id"))
		JCMDS(DEV_ID);
	else if(!strcmp(argv[1], "count")) 
		JCMDS(DEV_COUNT);
	else if(!strcmp(argv[1], "user"))
		JCMDS(DEV_USERCODE);
	else if(!strcmp(argv[1], "bsc"))
		JCMDS(DEV_BSC);
	else if(!strcmp(argv[1], "xsvf")) {
		int fd;
		int c;
		JCMDS(DEV_XSVF);
		if(argc != 3) {
			fprintf(stderr,"xsvf requires file\n");
			exit(-1);
		}
		if(stat(argv[2], &sb) == -1) {
			fprintf(stderr,"%s: %s\n", argv[2], strerror(errno));
			exit(-1);
		}
		if(!(xsvf=(uint8_t*)malloc(sb.st_size))) {
			perror("malloc: ");
			exit(-1);
		}
		if(-1==(fd=open(argv[2], O_RDONLY))) {
			fprintf(stderr,"%s: %s\n", argv[2], strerror(errno));
			exit(-1);
		}
		if((sb.st_size!=(c=read(fd, xsvf, sb.st_size)))) {
			fprintf(stderr,"%s: %s\n", argv[2], strerror(errno));
			exit(-1);
		}
		close(fd);
		xsvfSize=sb.st_size;
	} else {
		fprintf(stderr, "invalid argument: %s\n", argv[1]);
		exit(-1);
	}

/*
	if(argc != 2) {
		fprintf(stderr, "type string\n");
		exit(-1);
	}
	data=argv[1];
	data_len=strlen(data);
*/
	usb_init();
	usb_find_busses();
	usb_find_devices();

	dev = findDev();
	if(!dev) {
		perror("open device: ");
		exit(-1);
	}
/*
	if(usb_set_configuration(dev, 1) < 0) {
		perror("usb set config: ");
		exit(-1);
	}
*/
	if(usb_claim_interface(dev, 0)) {
		perror("claim interface: ");
		exit(-1);
	}
	if(sizeof(jtag_cmd_t)!=usb_bulk_write(dev, (1 | USB_ENDPOINT_OUT), PJCMD, sizeof(jtag_cmd_t),5000)) {
		perror("bulk transfer error: ");
		exit(-1);
	}
	usleep(1000);
	if(JCMD==DEV_XSVF) {
		uint8_t* pXsvf = xsvf;
		uint32_t i=0;

		while(xsvfSize) {
			int size = 64 < xsvfSize? 64 : xsvfSize;
			if(!(i++%8)) {
				printf("\rsending %d/%d", size, xsvfSize);
				fflush(stdout);
			}
			if(size!=usb_bulk_write(dev,(2 | USB_ENDPOINT_OUT), pXsvf, size,5000)) {
				perror("xsvf write error: ");
				exit(-1);
			}
			if(sizeof(jtag_cmd_t)!=usb_bulk_read(dev, (1 | USB_ENDPOINT_IN), PJCMD, sizeof(jtag_cmd_t), 35000)) {
				perror("xsvf read error: ");
				exit(-1);
			}
			pXsvf+=size;
			xsvfSize-=size;
			switch(JRES){
				case SUCCESS:
					fprintf(stderr, "\nsuccess %d\n", xsvfSize);
					break;
				case FAILURE:
					fprintf(stderr, "\nfailure %d\n", xsvfSize);
				case RDEV_MORE_DATA:
					break;
				default:
					fprintf(stderr, "xsvf bad request %x\n", JRES);
					exit(-1);
			}
			usleep(50000);
		}
	} else if(JCMD == DEV_BSC) {
		int32_t r=0;
		uint8_t bscData[BOUNDARY_BYTES]={0,};
		uint8_t* pBsc = bscData;
		int len = BOUNDARY_BYTES;
		int size = BOUNDARY_BYTES > JDATA_LEN ? JDATA_LEN : BOUNDARY_BYTES;
		int i;
		do {
			int size = len > JDATA_LEN ? JDATA_LEN : len;
			if(sizeof(jtag_cmd_t)!=usb_bulk_read(dev, (1 | USB_ENDPOINT_IN), PJCMD, sizeof(jtag_cmd_t), 25000)) {
				perror("bsc bulk read: ");
				exit(-1);
			}
			if(JCMD != DEV_BSC) {
				fprintf(stderr, "bad command %x\n", JCMD);
				exit(-1);
			}
			if(!r)
				r=RCOUNT;

			memcpy(pBsc, JDATA, size);
			pBsc+=size;
			len-=size;
		} while(--r);
		for(r=0;r<BOUNDARY_BYTES;r++)
			printf("%x,", bscData[r]);
		for(r=BOUNDARY_BYTES-1;r>=0;r--) {
			if(bscData[r]!=0xff) {
				printf("pos: %d\n", (BOUNDARY_BYTES-1-r)*8);
			}
		}
/*
		for(r=0;r<BOUNDARY_BYTES;r++) {
			if(bscData[r]!=0xff)
				printf("pos: %d\n", r*8);
		}
*/
		printf("\n");
	} else{
		JRES=RESNONE;
		for(i=0;i<1;i++) {
			act=usb_bulk_read(dev, (1 | USB_ENDPOINT_IN), PJCMD, sizeof(jtag_cmd_t), 5000);
			if(act > 0 && act <= sizeof(jtag_cmd_t)) {
				switch(JRES) {
					case RESNONE:
						printf("resnone\n");
						break;
					case SUCCESS:
						printf("success\n");
						break;
					case FAILURE:
						printf("failure\n");
						break;
				}		
				printf("%x\n", JVAL);
			} else {
				fprintf(stderr,"%d\n", act);
				perror("bulk read: ");
				exit(-1);
			}
		}
	}
	if(usb_release_interface(dev,0)) {
		perror("release interface: ");
		exit(-1);
	}
	usb_close(dev);
	if(xsvf) {
		free(xsvf);
	}

	return 0;
}
