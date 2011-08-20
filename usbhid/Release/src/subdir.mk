################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/cr_startup_lpc13.c \
../src/gpio.c \
../src/hiduser.c \
../src/jtag.c \
../src/lenval.c \
../src/main.c \
../src/micro.c \
../src/ports.c \
../src/usbcore.c \
../src/usbdesc.c \
../src/usbhw.c \
../src/usbuser.c 

OBJS += \
./src/cr_startup_lpc13.o \
./src/gpio.o \
./src/hiduser.o \
./src/jtag.o \
./src/lenval.o \
./src/main.o \
./src/micro.o \
./src/ports.o \
./src/usbcore.o \
./src/usbdesc.o \
./src/usbhw.o \
./src/usbuser.o 

C_DEPS += \
./src/cr_startup_lpc13.d \
./src/gpio.d \
./src/hiduser.d \
./src/jtag.d \
./src/lenval.d \
./src/main.d \
./src/micro.d \
./src/ports.d \
./src/usbcore.d \
./src/usbdesc.d \
./src/usbhw.d \
./src/usbuser.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU C Compiler'
	arm-none-eabi-gcc -D__USE_CMSIS=CMSISv1p30_LPC13xx -DNDEBUG -D__CODE_RED -D__REDLIB__ -I"/home/fpga/Documents/workspace/CMSISv1p30_LPC13xx/inc" -I"/home/fpga/Documents/workspace/usbhid/inc" -O0 -Os -mword-relocations -g -Wall -c -fmessage-length=0 -fno-builtin -ffunction-sections -mcpu=cortex-m3 -mthumb -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


