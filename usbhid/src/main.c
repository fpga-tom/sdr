/*----------------------------------------------------------------------------
 *      Name:    DEMO.C
 *      Purpose: USB HID Demo
 *      Version: V1.20
 *----------------------------------------------------------------------------
 *      This software is supplied "AS IS" without any warranties, express,
 *      implied or statutory, including but not limited to the implied
 *      warranties of fitness for purpose, satisfactory quality and
 *      noninfringement. Keil extends you a royalty-free right to reproduce
 *      and distribute executable files created using this software for use
 *      on NXP Semiconductors LPC microcontroller devices only. Nothing else 
 *      gives you the right to use this software.
 *
 * Copyright (c) 2009 Keil - An ARM Company. All rights reserved.
 *---------------------------------------------------------------------------*/

#include "LPC13xx.h"                        /* LPC13xx definitions */

#include "usb.h"
#include "usbcfg.h"
#include "usbhw.h"
#include "usbreg.h"
#include "usbcore.h"
#include "config.h"
#include "jtag.h"

#define     EN_TIMER32_1    (1<<10)
#define     EN_IOCON        (1<<16)
#define     EN_USBREG       (1<<14)


/*
 *  Get HID Input Report -> InReport
 */

void GetInReport ()
{
}


/*
 *  Set HID Output Report <- OutReport
 */
void SetOutReport ()
{

}

/*
void zapni(int i) {
	GPIOSetValue( 1, 5, i&1 );
}

void vypni() {
	GPIOSetValue( LED_PORT, LED_BIT, 0 );
	GPIOSetValue( 1, 5, 0 );
}

void zapniJtag() {
	GPIOSetValue( 2, 0, 1 );
	GPIOSetValue( 2, 1, 1 );
	GPIOSetValue( 1, 5, 1 );
	GPIOSetValue( 1, 8, 1 );
	zapniCervenu();
}
*/
int main (void)
{
	jtagInit();
//	jtagMode();
//	jtagUserId();

	/* Enable Timer32_1, IOCON, and USB blocks */
	LPC_SYSCON->SYSAHBCLKCTRL |= (EN_TIMER32_1 | EN_IOCON | EN_USBREG);

	/* PLL and pin init function */
	USBIOClkConfig();

	/* USB Initialization */
	USB_Init();

	/* USB Connect (if SoftConnect switch implemented) */
	USB_Connect(1);
	/*
	r=RdCmdDat(CMD_SET_MODE);
	r|=INAK_AI;
	*/
	WrCmdDat(CMD_SET_MODE, DAT_WR_BYTE(INAK_AI));
	USB_ClearEPBuf(USB_ENDPOINT_IN(1));
	while(1) {
		if(QSTATE(XSVF_PLAY)) {
			uint32_t i=0;
			jtagMode();
			zapniCervenu();
			if(!xsvfExecute())
				jtagSuccess();
			else
				jtagFailure();
			vypniCervenu();
			CLR(XSVF_PLAY);
		}
		__WFI();
	}
}
