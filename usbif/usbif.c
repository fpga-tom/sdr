#define ALLOCATE_EXTERN
#include "fx2.h"
#include "fx2regs.h"
#include "intrins.h"
#include "fx2sdly.h"


// write single byte to PERIPHERAL, using GPIF
void Peripheral_SingleByteWrite( BYTE gdata )
{
while( !( GPIFTRIG & 0x80 ) ) // poll GPIFTRIG.7 Done bit
{
_nop_();
}
XGPIFSGLDATLX = gdata; // trigger GPIF
// ...single byte write transaction
}

	  /*
// read single byte from PERIPHERAL, using GPIF
void Peripheral_SingleByteRead( BYTE xdata *gdata )
{
static BYTE g_data = 0x00;
while( !( GPIFTRIG & 0x80 ) )
{
;
}
// poll GPIFTRIG.7 Done bit
// using registers in XDATA space, dummy read
g_data = XGPIFSGLDATLX;
// trigger GPIF
// ...single byte read transaction
while( !( GPIFTRIG & 0x80 ) ) // poll GPIFTRIG.7 Done bit
{
;
}
// using registers in XDATA space,
*gdata = XGPIFSGLDATLNOX;
// ...GPIF reads byte from PERIPHERAL
}
		*/


#define NOP _nop_()

unsigned char in_count, out_count;

#define BLOCKSIZE 512

void init_ep6buf(void)
{
int i;
xdata unsigned char *p;
p=EP6FIFOBUF;
i=BLOCKSIZE;
while(i>0){
	*p=0xaa;
	p++;
	i--;
	}
/* configure ep6 to be quad buffered */
EP6CFG=(EP6CFG & ~3)|3;
}

void fire_ep2buf() {
	EP2BCH=0xff;
	SYNCDELAY;
	EP2BCL=0xff;
	SYNCDELAY;
}

void init_ep2buf() {
//	EP2CFG=(EP2CFG & ~3)|3;
	SYNCDELAY;
}



void fire_ep6buf(void)
{
EP6FIFOBUF[0]=in_count;
EP6FIFOBUF[1]=out_count; 
NOP;
EP6BCH=BLOCKSIZE >> 8;
NOP;
EP6BCL=BLOCKSIZE & 0xff;
}

void init_fx2(void)
{
in_count=0;
out_count=0;
CPUCS=0x10;
//IFCONFIG=0xC0;
NOP;
FIFORESET=0x80;
NOP;
FIFORESET=0;
NOP;
FIFORESET=2;
NOP;
FIFORESET=4;
NOP;
FIFORESET=6;
NOP;
FIFORESET=8;
NOP;
FIFORESET=0;
init_ep6buf();
fire_ep6buf();
init_ep2buf();
fire_ep2buf();
/* ep2 - write something to byte count value to rearm */
//NOP;
//EP2BCL=0xff;
//NOP;
//EP2BCL=0xff;
}

void GpifInit();
void main() {
	xdata unsigned char *p;
	int i;
	GpifInit();
	//Peripheral_SingleByteRead(&b);
	//Peripheral_SingleByteWrite(0x3a);
	init_fx2();
	while(1) {
		//Peripheral_SingleByteWrite(0x45);
		if(!(EP2CS & bmBIT2)) {
			p=EP2FIFOBUF;
			for(i=0;i<BLOCKSIZE;i++) {
				//Peripheral_SingleByteWrite(*p++);
				Peripheral_SingleByteWrite(*p++);
			}
			//if(i==0xff)
				fire_ep2buf();
		}
//	if((EP6CS & bmBIT2)){
//		in_count++;
//		EP6FIFOBUF[0]=in_count;
//		EP6FIFOBUF[1]=out_count; 
//
//		NOP;
//		EP6BCH=BLOCKSIZE >> 8;
//		NOP;
//		EP6BCL=BLOCKSIZE & 0xff;
//		}
	/* if(!(EP2CS & bmBIT2))do_endpoint2(); */
	}
}

