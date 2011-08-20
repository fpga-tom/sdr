#ifndef __FX2_H__
#define __FX2_H__

void init_buffers(void);
int start_usb_reader(char *bus_name, char *device_name, char *endpoint_c);

#endif
