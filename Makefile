#TODO: Add a directory for the compiled objects, as opposed to just cluttering the working directory
#Implement an autoreset function so that the 
#
#Usage: Set ARDDIR to the directory containing the github repository found here:
#https://github.com/arduino/Arduino
#There are some other steps to set the repository up for building for the Due, but I won't cover them here.
#
#To program the Due, erase the flash, then run "make upload",
#specifying the port on which the Arduino is running as PORT
#
#Example:
#make upload PORT=/dev/ttyACM0
#Your Arduino may exist on another port, like ttyUSB0
#

ARDDIR=/home/michael/Documents/Programming/arduino/Arduino
SAMDIR=$(ARDDIR)/build/linux/work/hardware/arduino/sam
SYSDIR=$(SAMDIR)/system
CC=$(ARDDIR)/build/linux/work/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-gcc
CXX=$(ARDDIR)/build/linux/work/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-g++
CXXAR=$(ARDDIR)/build/linux/work/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-ar
CXXOBJCOPY=$(ARDDIR)/build/linux/work/hardware/tools/g++_arm_none_eabi/bin/arm-none-eabi-objcopy
UPLOAD=$(ARDDIR)/build/linux/work/hardware/tools/bossac
UPLOADOPTS=-U false -e -w -v -b
INCDIRS=-I$(SYSDIR)/libsam -I$(SYSDIR)/CMSIS/CMSIS/Include/ -I$(SYSDIR)/CMSIS/Device/ATMEL/ -I$(SAMDIR)/cores/arduino -I$(SAMDIR)/variants/arduino_due_x
CFLAGS=-g -Os -w -ffunction-sections -fdata-sections -nostdlib --param max-inline-insns-single=500 -Dprintf=iprintf -mcpu=cortex-m3 -DF_CPU=84000000L -DARDUINO=152 -D__SAM3X8E__ -mthumb -DUSB_PID=0x003e -DUSB_VID=0x2341 -DUSBCON
CXXFLAGS=-g -Os -w -ffunction-sections -fdata-sections -nostdlib --param max-inline-insns-single=500 -fno-rtti -fno-exceptions -Dprintf=iprintf -mcpu=cortex-m3 -DF_CPU=84000000L -DARDUINO=152 -D__SAM3X8E__ -mthumb -DUSB_PID=0x003e -DUSB_VID=0x2341 -DUSBCON
LINKFLAGS=-Os -Wl,--gc-sections -mcpu=cortex-m3 -T/home/michael/Documents/Programming/arduino/Arduino/build/linux/work/hardware/arduino/sam/variants/arduino_due_x/linker_scripts/gcc/flash.ld -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -Wl,--entry=Reset_Handler -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -Wl,--warn-unresolved-symbols 

program.cpp.bin: test.c
	$(CXX) $(CXXFLAGS) $(INCDIRS) -c -o program.o test.c

	$(CXX) $(LINKFLAGS) -Wl,-Map,program.cpp.map -o program.cpp.elf -lm -lgcc -mthumb -Wl,--start-group syscalls_sam3.c.o program.o $(SAMDIR)/variants/arduino_due_x/libsam_sam3x8e_gcc_rel.a core.a -Wl,--end-group 
	$(CXXOBJCOPY) -O binary program.cpp.elf program.cpp.bin

upload: program.cpp.bin
	$(UPLOAD) --port=$(PORT) $(UPLOADOPTS) program.cpp.bin -R

core.a:
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/hooks.c -o hooks.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/wiring.c -o wiring.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/iar_calls_sam3.c -o iar_calls_sam3.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/WInterrupts.c -o WInterrupts.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/syscalls_sam3.c -o syscalls_sam3.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/wiring_digital.c -o wiring_digital.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/cortex_handlers.c -o cortex_handlers.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/wiring_shift.c -o wiring_shift.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/itoa.c -o itoa.c.o
	$(CC) -c $(CFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/wiring_analog.c -o wiring_analog.c.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/RingBuffer.cpp -o RingBuffer.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/IPAddress.cpp -o IPAddress.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/UARTClass.cpp -o UARTClass.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/USB/USBCore.cpp -o USBCore.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/USB/HID.cpp -o HID.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/USB/CDC.cpp -o CDC.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/Stream.cpp -o Stream.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/Reset.cpp -o Reset.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/WMath.cpp -o WMath.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/cxxabi-compat.cpp -o cxxabi-compat.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/wiring_pulse.cpp -o wiring_pulse.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/Print.cpp -o Print.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/WString.cpp -o WString.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/main.cpp -o main.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/cores/arduino/USARTClass.cpp -o USARTClass.cpp.o
	$(CXX) -c $(CXXFLAGS) $(INCDIRS) $(SAMDIR)/variants/arduino_due_x/variant.cpp -o variant.cpp.o

	$(CXXAR) rcs core.a hooks.c.o
	$(CXXAR) rcs core.a wiring.c.o
	$(CXXAR) rcs core.a iar_calls_sam3.c.o
	$(CXXAR) rcs core.a WInterrupts.c.o
	$(CXXAR) rcs core.a syscalls_sam3.c.o
	$(CXXAR) rcs core.a wiring_digital.c.o
	$(CXXAR) rcs core.a cortex_handlers.c.o
	$(CXXAR) rcs core.a wiring_shift.c.o
	$(CXXAR) rcs core.a itoa.c.o
	$(CXXAR) rcs core.a wiring_analog.c.o
	$(CXXAR) rcs core.a RingBuffer.cpp.o
	$(CXXAR) rcs core.a IPAddress.cpp.o
	$(CXXAR) rcs core.a UARTClass.cpp.o
	$(CXXAR) rcs core.a USBCore.cpp.o
	$(CXXAR) rcs core.a HID.cpp.o
	$(CXXAR) rcs core.a CDC.cpp.o
	$(CXXAR) rcs core.a Stream.cpp.o
	$(CXXAR) rcs core.a Reset.cpp.o
	$(CXXAR) rcs core.a WMath.cpp.o
	$(CXXAR) rcs core.a cxxabi-compat.cpp.o
	$(CXXAR) rcs core.a wiring_pulse.cpp.o
	$(CXXAR) rcs core.a Print.cpp.o
	$(CXXAR) rcs core.a WString.cpp.o
	$(CXXAR) rcs core.a main.cpp.o
	$(CXXAR) rcs core.a USARTClass.cpp.o
	$(CXXAR) rcs core.a variant.cpp.o
