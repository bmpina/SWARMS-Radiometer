##DB9 pin2 == 'received data'
##DB9 pin3 == 'transmit data'
##DB9 pin5 == 'signal ground'
##single RS-232 serial connection == 8 data bits, no parity, 1 stop bit, no flow control

import pyserial
import serial
import time

# configure the serial connections (the parameters differs on the device you are connecting to)
ser = serial.Serial(
	port='/dev/ttyUSB1', #port will change but as of yet to be known
	baudrate=1200,
	parity=serial.PARITY_NONE,
	stopbits=serial.STOPBITS_ONE,
	bytesize=serial.EIGHTBITS
)

ser.xonxoff = false #disable software flow control
ser.rtscts = false #disable harware (RTS/CTS) flow control
ser.dsrdtr = false #disable hardware (DSR/DTR) flow control 
ser.isOpen()

print 'Enter your commands below.\r\nInsert "exit" to leave the application.'

input=1  #for example comms talk to other pi
while 1 :
	# get keyboard input
	input = input(">> ")  #can change input to reflect anything with " "
	if input == 'exit':
		ser.close()
		exit()
	else:
		# send the character to the device
		# (note that I happend a \r\n carriage return and line feed to the characters - this is requested by my device)
		ser.write(input + '\r\n')
		out = ''
		# let's wait one second before reading output (let's give device time to answer)
		time.sleep(1)
		while ser.inWaiting() > 0:
			out += ser.read(1)
			
		if out != '':
			print ">>" + out
#during flight will need two 2 inputs
