/*
 * jtag.h
 *
 *  Created on: Jul 13, 2011
 *      Author: fpga
 */

#ifndef JTAG_H_
#define JTAG_H_

#include "config.h"

#ifdef USB_VENDOR_ID

#include "LPC13xx.h"
// JTAG ports
#define TDO_PORT 1
#define TDO_GPIO LPC_GPIO1
#define TDO_BIT 5
#define TDI_PORT 2
#define TDI_BIT 0
#define TMS_PORT 2
#define TMS_BIT 1
#define TCK_PORT 1
#define TCK_BIT 8
#define PROG_B_PORT 2
#define PROG_B_BIT 2
#define M0_PORT 3
#define M0_BIT 2
#define M1_PORT 3
#define M1_BIT 0
#define M2_PORT 3
#define M2_BIT 1


// JTAG instructions
#define SAMPLE 0x7
#define USERCODE 0x8
#define EXTEST 0xf


// state
#define XSVF_PLAY 1

#define STATE(x) (jtagState|=(x))
#define QSTATE(x) (jtagState&(x))
#define CLR(x) (jtagState&=~(x))

extern uint8_t jtagState;

void jtagInit();
void jtagRead();
void jtagWrite();
void jtagXSVF();
void jtagSuccess();
void jtagFailure();
static inline void udelay(uint32_t usec) {
	uint32_t i=0;
	for(;i<usec;i++) {
		__NOP();
		__NOP();
		__NOP();
		__NOP();
	}
}
uint8_t jtagReadByte();

#endif /* USB_VENDOR_ID */


// FSM commands
#define JTAG_SUCCESS 1
#define JTAG_FAILURE 2
#define DEV_COUNT 3
#define DEV_ID 4
#define DEV_XSVF 5
#define DEV_MORE_DATA 6
#define DEV_USERCODE 7
#define DEV_BSC 8

#define FSM_CMD_COUNT 9

// Response codes
#define RSHIFT 4 // response shift
#define RMASK ((1<<RSHIFT)-1) // repeat mask
#define REPEAT(x,c) ((((c) << RSHIFT) | ((x) & RMASK)))
#define RCOUNT (JRES&RMASK) // repeat count
#define RDEC JRES=(JRES&(~RMASK))|(RCOUNT-1)

#define RESNONE REPEAT(0,0)
#define SUCCESS REPEAT(1,JTAG_SUCCESS)
#define BSC(x) REPEAT(((x)+PKT_LEN-1)/JDATA_LEN,DEV_BSC)
#define RDEV_MORE_DATA REPEAT(1,DEV_MORE_DATA)
#define FAILURE REPEAT(1,JTAG_FAILURE)

#define PKT_LEN 0x40

typedef struct {
	union {
		uint8_t cmd;
		uint8_t res;
	} u;
	uint32_t val;
} __attribute__ ((packed)) jtag_hdr_t;

typedef struct {
	jtag_hdr_t cmd;
	uint8_t data[PKT_LEN-sizeof(jtag_hdr_t)];
} __attribute__ ((packed)) jtag_cmd_t;

typedef struct {
	jtag_cmd_t *cmd;
	unsigned int (*tx)(); // tx event
	unsigned (*rx)(); // rx event
} jtag_t;

extern jtag_cmd_t jtag;

#define PJCMD ((uint8_t*)(&jtag))
#define JCMDS(x) (jtag.cmd.u.cmd=(x)<<RSHIFT)
#define JCMD ((jtag.cmd.u.cmd>>RSHIFT)&RMASK)
#define JRES (jtag.cmd.u.res)
#define JVAL (jtag.cmd.val)
#define JDATA (jtag.data)
#define JDATA_LEN sizeof(JDATA)
#define BOUNDARY_LENGTH 637
#define BOUNDARY_BYTES ((BOUNDARY_LENGTH+7)/8)

#endif /* JTAG_H_ */
