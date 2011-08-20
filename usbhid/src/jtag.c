/*
 * jtag.c
 *
 *  Created on: Jul 13, 2011
 *      Author: fpga
 */
#include "LPC13xx.h"
#include "config.h"
#include "type.h"
#include "usb.h"
#include "usbcfg.h"
#include "usbcore.h"
#include "usbhw.h"
#include "ports.h"
#include "jtag.h"
#include "gpio.h"
#include "lenval.h"

uint8_t jtagState=0;
uint8_t data[BOUNDARY_BYTES];
uint8_t *pData;
int len=0;

static unsigned int jtagBscData();
static unsigned int jtagXsvf();
static unsigned int jtagDevId();
static unsigned int jtagDevCount();
static unsigned int jtagSample();
static unsigned int jtagUserId();
static unsigned int jtagMoreData();
static unsigned int _jtagSuccess();
static unsigned int _jtagFailure();

jtag_cmd_t jtag;
static jtag_t _jSuccess = {
		.cmd = &jtag,
		.rx = 0,
		.tx = _jtagSuccess,
};
static jtag_t _jFailure = {
		.cmd = &jtag,
		.rx = 0,
		.tx = _jtagFailure,
};
static jtag_t _devCount = {
		.cmd = &jtag,
		.rx = jtagDevCount,
		.tx = 0,
};
static jtag_t _devId = {
		.cmd = &jtag,
		.rx = jtagDevId,
		.tx = 0,
};
static jtag_t _devXsvf = {
		.cmd = &jtag,
		.rx = jtagXsvf,
		.tx = 0,
};
static jtag_t _devMoreData = {
		.cmd = &jtag,
		.rx = 0,
		.tx = jtagMoreData,
};
static jtag_t _devUsercode = {
		.cmd = &jtag,
		.rx = jtagUserId,
		.tx = 0,
};
static jtag_t _devBsc = {
		.cmd = &jtag,
		.rx = jtagSample,
		.tx = jtagBscData,
};


static jtag_t *jtagDoCmd[FSM_CMD_COUNT] = {
		0, 				// 0 pointer to current command
		&_jSuccess,		// 1
		&_jFailure,		// 2
		&_devCount, 	// 3
		&_devId, 		// 4
		&_devXsvf, 		// 5
		&_devMoreData,	// 6
		&_devUsercode, 	// 7
		&_devBsc, 		// 8
};

void zapniCervenu() {
	GPIOSetValue( LED_PORT, LED_BIT, 1 );
}

void vypniCervenu() {
	GPIOSetValue( LED_PORT, LED_BIT, 0 );
}


void jtagInit() {
	GPIOInit();
	GPIOSetDir( LED_PORT, LED_BIT, 1 );
	GPIOSetValue( LED_PORT, LED_BIT, 0 );

	GPIOSetDir( TDO_PORT, TDO_BIT, 0 );
	GPIOSetValue( TDO_PORT, TDO_BIT, 0 );

	GPIOSetDir( TDI_PORT, TDI_BIT, 1 );
	GPIOSetValue( TDI_PORT, TDI_BIT, 0 );

	GPIOSetDir( TMS_PORT, TMS_BIT, 1 );
	GPIOSetValue( TMS_PORT, TMS_BIT, 0 );

	GPIOSetDir( TCK_PORT, TCK_BIT, 1 );
	GPIOSetValue( TCK_PORT, TCK_BIT, 0 );

	GPIOSetDir(PROG_B_PORT, PROG_B_BIT, 1);
	GPIOSetValue(PROG_B_PORT, PROG_B_BIT, 1);

	GPIOSetDir(M0_PORT, M0_BIT, 1);
	GPIOSetValue(M0_PORT, M0_BIT, 0);

	GPIOSetDir(M1_PORT, M1_BIT, 1);
	GPIOSetValue(M1_PORT, M1_BIT, 0);

	GPIOSetDir(M2_PORT, M2_BIT, 1);
	GPIOSetValue(M2_PORT, M2_BIT, 0);
}

void jtagMode() {
	GPIOSetValue(M0_PORT, M0_BIT, 1);
	GPIOSetValue(M1_PORT, M1_BIT, 0);
	GPIOSetValue(M2_PORT, M2_BIT, 1);
	GPIOSetValue(PROG_B_PORT, PROG_B_BIT,0);
	udelay(10);
	GPIOSetValue(PROG_B_PORT, PROG_B_BIT,1);
	udelay(50000);
//	while(1);

}

void testLogicReset() {
	uint32_t i;
	for(i=0;i<5;i++) {
		setPort(TMS, 1);
		pulseClock();
	}
	setPort(TMS,0);
}

unsigned int _jtagSuccess() {
	JRES=SUCCESS;
	return SUCCESS;
}

unsigned int _jtagFailure() {
	JRES=FAILURE;
	return FAILURE;
}

void jtagSuccess() {
	jtagDoCmd[0]=jtagDoCmd[JTAG_SUCCESS];
}

void jtagFailure() {
	jtagDoCmd[0]=jtagDoCmd[JTAG_FAILURE];
}

unsigned int jtagDevId() {
	uint32_t i;
	uint32_t r=0;
	testLogicReset();

	setPort(TMS,0);
	pulseClock();
	setPort(TMS,1);
	pulseClock();
	setPort(TMS,0);
	pulseClock();
	pulseClock();
	for(i=0;i<32;i++) {
		pulseClock();
		r|=readTDOBit()<<i;
	}
	JVAL=r;
	return SUCCESS;

}

unsigned int jtagDevCount() {
	uint32_t i;
	testLogicReset();

	setPort(TMS,0);
	pulseClock();
	setPort(TMS,1);
	pulseClock();
	pulseClock();
	setPort(TMS,0);
	pulseClock();
	pulseClock();

	for(i=0;i<999;i++) {
		setPort(TDI,1);
		pulseClock();
	}
	setPort(TDI,1);
	setPort(TMS,1);
	pulseClock();
	setPort(TDI,0);

	setPort(TMS,1);
	pulseClock();
	pulseClock();
	setPort(TMS,0);
	pulseClock();
	pulseClock();

	for(i=0;i<1000;i++)
		pulseClock();
	for(i=0;i<1000;i++) {
		setPort(TDI,1);
		pulseClock();
		if(readTDOBit()) {
			break;
		}
	}
	JVAL=i;
	return SUCCESS;
}

extern int xsvfGotoTapState( unsigned char*   pucTapState,
                      unsigned char    ucTargetState );
extern void xsvfShiftOnly( long    lNumBits,
                    lenVal* plvTdi,
                    lenVal* plvTdoCaptured,
                    int     iExitShift );

unsigned int jtagUserId() {
	uint32_t i,r=0,in=0;
	lenVal tdi;
	lenVal tdoCapt;
	unsigned char c = 0;
	tdi.len = 1;
	tdi.val[0] = USERCODE;

	i=xsvfGotoTapState(&c, 0);
	i=xsvfGotoTapState(&c, 1);
	i=xsvfGotoTapState(&c, 0xb);
	xsvfShiftOnly(6, &tdi,&tdoCapt, 1);
//	setPort(TMS,0);
//	pulseClock();
//	r=USERCODE;
//	for(i=0;i<6;i++) {
//		setPort(TDI, r&1);
//		pulseClock();
//		in|=readTDOBit()<<i;
//		r>>=1;
//	}
	c=0xc;
	i=xsvfGotoTapState(&c, 0x1);
//	pulseClock();
	i=xsvfGotoTapState(&c, 0x4);
//	tdi.len=4;
//	tdoCapt.val[0]=tdoCapt.val[1]=tdoCapt.val[2]=tdoCapt.val[3]=0xaa;
//	xsvfShiftOnly(32, &tdi,&tdoCapt, 0);
//	i=xsvfGotoTapState(&c,0x1);
	in=0xdeadbeef;
	for(i=0;i<32;i++) {
		setPort(TDI, in&1);
		in>>=1;
		pulseClock();
//		if(i>0)
		r|=readTDOBit()<<(i-0);
	}
//	r|=readTDOBit()<<(i-1);
//	r=0;
//	for(i=0;i<32;i++) {
//		pulseClock();
//	}

	JVAL=r;
	return SUCCESS;
}

unsigned int jtagXsvf() {
	len=0;
	STATE(XSVF_PLAY);
	jtagDoCmd[0]=0;
	return SUCCESS;
}

unsigned int jtagSample() {
	uint8_t c,i;
	uint32_t r=0;
	lenVal tdi,tdo;
	tdi.len = 1;
	tdi.val[0] = SAMPLE;
//	initLenVal(&tdi, SAMPLE);
	initLenVal(&tdo, 0);

	if(xsvfGotoTapState(&c,0))
		return FAILURE;
	if(xsvfGotoTapState(&c,1))
		return FAILURE;
	if(xsvfGotoTapState(&c, 0xb))
		return FAILURE;
	xsvfShiftOnly(6, &tdi, &tdo, 1);
	c=0xc;
	if(xsvfGotoTapState(&c, 1))
		return FAILURE;
	if(xsvfGotoTapState(&c, 0x4))
		return FAILURE;
	tdi.len=BOUNDARY_BYTES;
	for(i=0;i<BOUNDARY_BYTES;i++)
		tdi.val[i]=0;
		/*
		if(i<BOUNDARY_BYTES/128)
			tdi.val[i]=0;
		else
			tdi.val[i]=0xff;
		*/
	xsvfShiftOnly(BOUNDARY_LENGTH, &tdi, &tdo, 0);

//	tdo.val[(BOUNDARY_LENGTH-1-606)/8]&=~(1<<(7-((BOUNDARY_LENGTH-1-606)%8)));
//	tdo.val[(BOUNDARY_LENGTH-1-607)/8]|=(1<<(7-((BOUNDARY_LENGTH-1-607)%8)));
//	tdo.val[(BOUNDARY_LENGTH-1-608)/8]&=~(1<<(7-((BOUNDARY_LENGTH-1-608)%8)));

#define B (BOUNDARY_BYTES*8)
	tdo.val[0]=0x1c;
//	tdo.val[(607)/8]&=~(1<<(607%8));
//	tdo.val[(608)/8]&=~(1<<(608%8));
	xsvfShiftOnly(BOUNDARY_LENGTH,&tdo,&tdi,1);
//	xsvfShiftOnly(BOUNDARY_LENGTH,&tdo,&tdi,1);
	for(c=0;c<BOUNDARY_BYTES;c++) {
		data[c]=tdo.val[c];
	}
	pData = data;
	len=c;

	c=0x5;
	if(xsvfGotoTapState(&c, 0x1))
		return FAILURE;
	if(xsvfGotoTapState(&c, 0xb))
		return FAILURE;
	tdi.len=1;
	tdi.val[0] = EXTEST;
	xsvfShiftOnly(6, &tdi, &tdo, 1);
	c=0xc;
	if(xsvfGotoTapState(&c, 0x1))
		return FAILURE;

	return BSC(BOUNDARY_BYTES);
}

unsigned int jtagBscData() {
	uint32_t i=0;
	for(i=0;i<JDATA_LEN && len>0;i++,len--) {
		JDATA[i]=*pData++;
	}
	return SUCCESS;
}

unsigned int jtagMoreData() {
	JRES=RDEV_MORE_DATA;
	return SUCCESS;
}


void jtagXSVF() {
	if(!len) {
		pData=data;
		len=USB_ReadEP(USB_ENDPOINT_OUT(2), data);
	}
}

uint8_t jtagReadByte() {
	if(!len) {
		while(jtagDoCmd[0]);
		jtagDoCmd[0]=jtagDoCmd[DEV_MORE_DATA];
		while(!len);
	}
	len--;
	return *pData++;
}

void jtagRead() {
	int i = USB_ReadEP(USB_ENDPOINT_OUT(1), PJCMD);

	if(i) {
		if(JCMD < FSM_CMD_COUNT && jtagDoCmd[JCMD]) {
			jtagDoCmd[0] = jtagDoCmd[JCMD];
			if(jtagDoCmd[0]->rx)
				JRES=jtagDoCmd[0]->rx();
		}
	}
}

void jtagWrite() {
	if(jtagDoCmd[0]) {
		udelay(1000);
		if(jtagDoCmd[0]->tx)
			jtagDoCmd[0]->tx();
		USB_WriteEP(USB_ENDPOINT_IN(1), PJCMD, sizeof(jtag_cmd_t));
		RDEC;
		if(!(RCOUNT))
			jtagDoCmd[0]=NULL;
	}
}
