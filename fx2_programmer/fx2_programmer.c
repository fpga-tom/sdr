#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
/* needed for stat() */
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
/* needed for usb functions */
#include <usb.h>

void *do_alloc(long a, long b)
{
void *p;
if(a<1)a=1;
if(b<1)b=1;
p=calloc(a,b);
while(p==NULL){
	fprintf(stderr,"Failed to allocate %ld chunks of %ld bytes each (%ld bytes total)\n", a,b,a*b);
	sleep(1);
	p=calloc(a,b);
	}
return p;
}

int atoz(char *s)
{
int a;
if(!strncasecmp("0x", s, 2)){
	sscanf(s, "%x", &a);
	return a;
	}
return atoi(s);
}

void dump_busses(void)
{
struct usb_bus *p;
struct usb_device *q;
p=usb_busses;
printf("Dump of USB subsystem:\n");
while(p!=NULL){
	q=p->devices;
	while(q!=NULL){
		printf(" bus %s device %s vendor id=0x%04x product id=0x%04x %s\n", 
			p->dirname, q->filename, q->descriptor.idVendor, q->descriptor.idProduct,
			(q->descriptor.idVendor==0x4b4) && (q->descriptor.idProduct==0x8613)?
			"(UNCONFIGURED FX2)":"");
		q=q->next;
		}
	p=p->next;
	}
fflush(stdout);
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

void dump_ram(int start, int len)
{
unsigned char buffer[64];
int i;
int tlen;
int quanta=16;
int a;
for(i=start;i<start+len;i+=quanta){
	tlen=len+start-i;
	if(tlen>quanta)tlen=quanta;
	a=usb_control_msg(current_handle, 0xc0, 0xa0, i, 0, buffer, tlen, 1000);
	if(a<0){
		fprintf(stderr,"Request to download ram contents failed: %s\n", usb_strerror());
		return;
		}
	printf("0x%04x:", i);
	for(a=0;a<tlen;a++)printf(" %02x", buffer[a]);
	printf("\n");
	}

fflush(stdout);
}

#define MAX_CHUNKSIZE  128*1024

void dump_bulkdata(int endpoint, int len, int chunk)
{
unsigned char buffer[MAX_CHUNKSIZE];
int i;
int tlen;
int a;
if(chunk>MAX_CHUNKSIZE){
	fprintf(stderr,"Unsupported chunk value: %d, should be less or equal to %d\n", chunk, MAX_CHUNKSIZE);
	return;
	}
if(usb_claim_interface(current_handle, 0)<0){
	fprintf(stderr,"Could not claim interface 0: %s\n", usb_strerror());
	return;
	}
usb_set_altinterface(current_handle, 1);
for(i=0;i<len;i+=chunk){
	tlen=len-i;
	if(tlen>chunk)tlen=chunk;
	a=usb_bulk_read(current_handle, endpoint, buffer, tlen, 1000);
	if(a<0){
		fprintf(stderr,"Request for bulk read of %d bytes failed: %s\n", tlen, usb_strerror());
		usb_release_interface(current_handle, 0);
		return;
		}
	printf("0x%04x:", i);
	for(a=0;a<tlen;a++)printf(" %02x", buffer[a]);
	printf("\n");
	}
fflush(stdout);
usb_release_interface(current_handle, 0);
}


void bench_bulk(int endpoint, int len, int chunk)
{
unsigned char buffer[MAX_CHUNKSIZE];
int i;
int tlen;
int a;
struct timeval tv1,tv2;
long long usec;
if(chunk>MAX_CHUNKSIZE){
	fprintf(stderr,"Unsupported chunk value: %d, should be less or equal to %d\n", chunk, MAX_CHUNKSIZE);
	return;
	}
if(usb_claim_interface(current_handle, 0)<0){
	fprintf(stderr,"Could not claim interface 0: %s\n", usb_strerror());
	return;
	}
usb_set_altinterface(current_handle, 1);
gettimeofday(&tv1, NULL);
for(i=0;i<len;i+=chunk){
	tlen=len-i;
	if(tlen>chunk)tlen=chunk;
	a=usb_bulk_read(current_handle, endpoint, buffer, tlen, 1000);
	if(a<0){
		fprintf(stderr,"Request for bulk read failed: %s\n", usb_strerror());
		usb_release_interface(current_handle, 0);
		return;
		}
	}
gettimeofday(&tv2, NULL);
usec=tv2.tv_sec*1000000+tv2.tv_usec;
usec-=tv1.tv_sec*1000000+tv1.tv_usec;
printf("Read %d bytes in %ld seconds and %ld microseconds. Rate of %ld bytes/second\n",
	len, (long)usec/1000000, (long)usec % 1000000, (long)(((long long)len*1000000)/usec));
fflush(stdout);
usb_release_interface(current_handle, 0);
}

void upload_ram(unsigned char *buf, int start, int len)
{
int i;
int tlen;
int quanta=16;
int a;
for(i=start;i<start+len;i+=quanta){
	tlen=len+start-i;
	if(tlen>quanta)tlen=quanta;
	a=usb_control_msg(current_handle, 0x40, 0xa0, i, 0, buf+(i-start), tlen, 1000);
	if(a<0){
		fprintf(stderr,"Request to upload ram contents failed: %s\n", usb_strerror());
		return;
		}
	}

}

void upload_file(char *filename, int start, int len)
{
char *buf;
FILE *f;
buf=do_alloc(len, sizeof(char));
f=fopen(filename, "r");
if(f==NULL){
	fprintf(stderr,"Cannot open file \"%s\" for reading:", filename);
	perror("");
	return;
	}
fread(buf, 1, len, f);
upload_ram(buf, start, len);
fclose(f);
}

void upload_file_SDR2(char *filename, int endpoint)
{
char *buf;
unsigned char buf2[512];
unsigned char *s;
long len, tlen, i;
int a;
struct stat st_buf;
FILE *f;
if(stat(filename, &st_buf)<0){
	fprintf(stderr,"Error finding length of file \"%s\":", filename);
	perror("");
	return;
	}
len=st_buf.st_size;
buf=do_alloc(len, sizeof(char));
f=fopen(filename, "r");
if(f==NULL){
	fprintf(stderr,"Cannot open file \"%s\" for reading:", filename);
	perror("");
	return;
	}
fread(buf, 1, len, f);
fclose(f);

if(usb_claim_interface(current_handle, 0)<0){
	fprintf(stderr,"Could not claim interface 0: %s\n", usb_strerror());
	return;
	}
usb_set_altinterface(current_handle, 1);
memset(buf2, 0, 512);
buf2[0]=0x03;
buf2[1]=0x00;
buf2[2]=0x00;

a=usb_bulk_write(current_handle, endpoint, buf2, 512, 1000);
if(a<0){
	fprintf(stderr,"Request for bulk write failed: %s\n", usb_strerror());
	usb_release_interface(current_handle, 0);
	return;
	}
s=buf;
for(i=0;i<len;i+=509){
	tlen=len-i;
	if(tlen>509)tlen=509;
	buf2[0]=0x04;
	buf2[1]=(tlen*8)>>8;
	buf2[2]=(tlen*8)& 0xff;
	s+=tlen;
	memcpy(&(buf2[3]), s, tlen);
	a=usb_bulk_write(current_handle, endpoint, buf2, 512, 1000);
	if(a<0){
		fprintf(stderr,"Request for bulk write failed: %s\n", usb_strerror());
		usb_release_interface(current_handle, 0);
		return;
		}
	}
usb_release_interface(current_handle, 0);
}

void program_fx2(char *filename)
{
FILE *f;
unsigned char s[1024];
int length;
int addr;
int type;
unsigned char data[256];
unsigned char checksum,a;
unsigned int b;
int i;
f=fopen(filename, "r");
if(f==NULL){
	fprintf(stderr,"Cannot open file \"%s\" for reading:", filename);
	perror("");
	return;
	}
printf("Using file \"%s\"\n", filename);
while(!feof(f)){
	fgets(s, 1024, f); /* we should not use more than 263 bytes normally */
	if(s[0]!=':'){
		fprintf(stderr,"%s: invalid string: \"%s\"\n", filename, s);
		continue;
		}
	sscanf(s+1, "%02x", &length);
	sscanf(s+3, "%04x", &addr);
	sscanf(s+7, "%02x", &type);
	if(type==0){
		printf("Programming %3d byte%s starting at 0x%04x", length, length==1?" ":"s", addr);
		a=length+(addr &0xff)+(addr>>8)+type;
		for(i=0;i<length;i++){
			sscanf(s+9+i*2,"%02x", &b);
			data[i]=b;
			a=a+data[i];
			}
		sscanf(s+9+length*2,"%02x", &b);
		checksum=b;
		if(((a+checksum)&0xff)!=0x00){
			printf("  ** Checksum failed: got 0x%02x versus 0x%02x\n", (-a)&0xff, checksum);
			continue;
			} else {
			printf(", checksum ok\n");
			}
		upload_ram(data, addr, length);
		} else 
	if(type==0x01){
		printf("End of file\n");
		fclose(f);
		return;
		} else
	if(type==0x02){
		printf("Extended address: whatever I do with it ?\n");
		continue;
		}
	}
fclose(f);
}

void bulk_write(int endpoint, int count, char *bytes[])
{
int i,a;
unsigned char buf[512];

if(count>512){
	fprintf(stderr, "Cannot transfer more than 512 bytes at a time.\n");
	return;
	}

if(usb_claim_interface(current_handle, 0)<0){
	fprintf(stderr,"Could not claim interface 0: %s\n", usb_strerror());
	return;
	}
usb_set_altinterface(current_handle, 1);
memset(buf, 0, 512);
for(i=0;i<count;i++)buf[i]=atoz(bytes[i]);

a=usb_bulk_write(current_handle, endpoint, buf, count, 1000);
if(a<0){
	fprintf(stderr,"Request for bulk write failed: %s\n", usb_strerror());
	usb_release_interface(current_handle, 0);
	return;
	}
usb_release_interface(current_handle, 0);
}

void program_eeprom(char *filename, unsigned char eeprom_address)
{
unsigned char buf[64];
unsigned short address;
int len;
int a;
FILE *f;
f=fopen(filename, "r");
if(f==NULL){
	fprintf(stderr,"Cannot open file \"%s\" for reading:", filename);
	perror("");
	return;
	}
address=0;
buf[0]=2;
buf[1]=eeprom_address;
while(!feof(f)){
	len=fread(buf+5, 1, 59, f);
	if(len==0)break;
	buf[2]=len+2;
	buf[3]=(address>>8) & 0xFF;
	buf[4]=(address & 0xFF);
	a=usb_bulk_write(current_handle, 2, buf, len+5, 1000);
	if(a<0){
		fprintf(stderr,"Request for bulk write failed.\n");
		return;
		}
	}
fclose(f);
}

void play(char *filename) {
	unsigned char buf[512];
	ssize_t len;
	struct stat sb;
	int a;
	int fd;
	printf("%s\n", filename);
	if(stat(filename, &sb) == -1) {
		perror("stat: ");
		exit(-1);
	}
	len = sb.st_size;
	if((fd=open(filename, O_RDONLY)) == -1) {
		perror("open play\n");
		exit(-1);
	}
if(usb_claim_interface(current_handle, 0)<0){
	fprintf(stderr,"Could not claim interface 0: %s\n", usb_strerror());
	return;
	}
usb_set_altinterface(current_handle, 1);
	while(len > 0) {
		if((a=read(fd, buf, 512)) == -1) {
			perror("read\n");
			exit(-1);
		}
		if(0>usb_bulk_write(current_handle, (2|USB_ENDPOINT_OUT), buf, 512, 1000)) {
			fprintf(stderr, "Request for bulk write failed\n");
			perror("write error: ");
			exit(-1);
		}
		len-=a;
		printf("len: %d\n",len);
	}
usb_release_interface(current_handle, 0);
	close(fd);
}

void show_help(void)
{
printf( "\nfx2_programmer  bus device function [parameters]\n"
	"\n"
	"   Function       Parameters            Description\n"
	"   dump_busses                          show all available devices\n"
	"   dump           start len             dump RAM contents\n"
	"   bulk_dump      endpoint len chunk    dump data read of bulk endpoint\n"
	"   bulk_bench     endpoint len chunk    benchmark throughput of bulk endpoint\n"
	"   bulk_write     endpoint byte1 ...    write bytes to bulk endpoint\n"
	"   upload         file start len        upload binary file to RAM\n"
	"   upload_SDR2    file endpoint         upload binary file to endpoint in SDR2 format\n"
	"   set            address byte          changes values of a single byte\n"
	"   program        file.ihx              programs fx2 using Intel hex format file\n"
	"   program_eeprom file I2C_address      program eeprom\n"
	"\n"
	);
}

int main(int argc, char *argv[])
{
char *bus_name="001", *device_name="003";
char a;
if(argc<4){
	show_help();
	return -1;
	}
usb_init();
usb_find_busses();
usb_find_devices();
if(!strcasecmp(argv[3], "dump_busses")){
	dump_busses();
	return 0;
	}
bus_name=argv[1];
device_name=argv[2];
current_device=find_device(bus_name, device_name);
if(current_device==NULL){
	fprintf(stderr,"Cannot find device %s on bus %s\n", device_name, bus_name);
	return -1;
	}
fprintf(stderr,"Using device %s on bus %s vendor id 0x%04x product id 0x%04x\n",
	device_name, bus_name, current_device->descriptor.idVendor, current_device->descriptor.idProduct);
current_handle=usb_open(current_device);
if(!strcasecmp(argv[3], "dump")){
	if(argc<6){
		fprintf(stderr,"Incorrect dump command syntax\n");
		return -1;
		}
	dump_ram(atoz(argv[4]), atoz(argv[5]));
	return 0;
	}
else if(!strcasecmp(argv[3], "bulk_dump")){
	if(argc<7){
		fprintf(stderr,"Incorrect bulk_dump command syntax\n");
		return -1;
		}
	dump_bulkdata(atoz(argv[4]), atoz(argv[5]), atoz(argv[6]));
	return 0;
	}
else if(!strcasecmp(argv[3], "bulk_bench")){
	if(argc<7){
		fprintf(stderr,"Incorrect bulk_bench command syntax\n");
		return -1;
		}
	bench_bulk(atoz(argv[4]), atoz(argv[5]), atoz(argv[6]));
	return 0;
	}
else if(!strcasecmp(argv[3], "upload")){
	if(argc<7){
		fprintf(stderr,"Incorrect upload command syntax\n");
		return -1;
		}
	upload_file(argv[4], atoz(argv[5]), atoz(argv[6]));
	return 0;
	}
else if(!strcasecmp(argv[3], "upload_SDR2")){
	if(argc<6){
		fprintf(stderr,"Incorrect upload command syntax\n");
		return -1;
		}
	upload_file_SDR2(argv[4], atoz(argv[5]));
	return 0;
	}
else if(!strcasecmp(argv[3], "set")){
	if(argc<6){
		fprintf(stderr,"Incorrect set command syntax\n");
		return -1;
		}
	a=atoz(argv[5]);
	upload_ram(&a, atoz(argv[4]), 1);
	return 0;
	}
else if(!strcasecmp(argv[3], "program")){
	if(argc<5){
		fprintf(stderr,"Incorrect program command syntax\n");
		return -1;
		}
	program_fx2(argv[4]);
	return 0;
	}
else if(!strcasecmp(argv[3], "bulk_write")){
	if(argc<6){
		fprintf(stderr,"Incorrect program command syntax\n");
		return -1;
		}
	bulk_write(atoz(argv[4]), argc-5, argv+5);
	return 0;
	}
else if(!strcasecmp(argv[3], "program_eeprom")){
	if(argc<6){
		fprintf(stderr,"Incorrect program command syntax\n");
		return -1;
		}
	program_eeprom(argv[4], atoz(argv[5]));
	return 0;
	}
else if(!strcasecmp(argv[3], "play")) {
	if(argc<5) {
		fprintf(stderr, "Incorrect program command syntax\n");
		return -1;
	}	
	play(argv[4]);
	return 0;
}
usb_close(current_handle);
return 0;
}
