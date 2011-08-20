#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
/* needed for stat() */
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
/* needed for usb functions */
#include <usb.h>
#include <pthread.h>

#include "fx2.h"

int atoz(char *s)
{
int a;
if(!strncasecmp("0x", s, 2)){
        sscanf(s, "%x", &a);
        return a;
        }
return atoi(s);
}

struct usb_device *find_device(char *busname, char *devicename)
{
struct usb_bus *p;
struct usb_device *q;
p=usb_busses;
while(p!=NULL){
	q=p->devices;
	if(strcmp(p->dirname, busname)){
		p=p->next;
		continue;
		}
	while(q!=NULL){
		if(!strcmp(q->filename, devicename))return q;
		q=q->next;
		}
	p=p->next;
	}
return NULL;
}

struct usb_device *current_device;
usb_dev_handle *current_handle;
int endpoint=0x86;
pthread_t usb_thread;

int nbuffers=10;
int last_buffer=0;
unsigned char **buffers;
int chunk_size=512*128;
int chunks=0;

void *do_alloc(long, long);

void init_buffers(void)
{
int i;
buffers=do_alloc(nbuffers, sizeof(*buffers));
for(i=0;i<nbuffers;i++)
	buffers[i]=do_alloc(chunk_size, sizeof(*buffers[i]));

}

void usb_reader_done(void)
{
usb_release_interface(current_handle, 0);
usb_close(current_handle);
}

int stop=0;

void * usb_reader(void *arg)
{
int a;
while(1){
	a=usb_bulk_read(current_handle, endpoint, buffers[last_buffer], chunk_size, 1000);
	if(a<0){
		fprintf(stderr,"Request for bulk read of %d bytes failed: %s\n", chunk_size, usb_strerror());
		} else {
		chunks++;
		last_buffer++;
		if(last_buffer>=nbuffers)last_buffer=0;
		}
	if(stop){
		usb_reader_done();
		exit(0);
		}
	}
}

int start_usb_reader(char *bus_name, char *device_name, char *endpoint_c)
{
usb_init();
usb_find_busses();
usb_find_devices();

current_device=find_device(bus_name, device_name);
endpoint=atoz(endpoint_c);

if(current_device==NULL){
	fprintf(stderr, "Could not find device %s on bus %s\n", device_name, bus_name);
	return -1;
	}

fprintf(stderr,"Using device %s on bus %s vendor id 0x%04x product id 0x%04x\n",
	device_name, bus_name, current_device->descriptor.idVendor, current_device->descriptor.idProduct);

current_handle=usb_open(current_device);

if(usb_claim_interface(current_handle, 0)<0){
	fprintf(stderr,"Could not claim interface 0: %s\n", usb_strerror());
	return -1;
	}

usb_set_altinterface(current_handle, 1);

pthread_create(&usb_thread, NULL, usb_reader, NULL);

return 0;
}
