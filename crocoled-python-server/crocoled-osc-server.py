#!/usr/bin/python 

# OSC to Arduino Bridge server
# Olivier Gauthier oligau@oscille.ca
# 
# Using pyOSC 0.3.5b-5294 for Python 2.7 to receive OSC messages from 
# Processing patch
# It then sends the frame buffer back to Arduino using Yun Bridge
# library.

 
import sys
from time import sleep

sys.path.insert(0, '/usr/lib/python2.7/bridge')
from bridgeclient import BridgeClient as bridgeclient

# pyOSC 0.3.5b-5294 OSC.py
from OSC import OSCServer

# [LED1_GREEN, LED1_RED, LED1_BLUE,LED2_GREEN, LED2_RED, LED2_BLUE]
frameArray1 = [255, 0, 0, 0, 255, 0]
frameArray2 = [0, 255, 0, 0, 0, 255]
frameArray3 = [0, 0, 255, 255, 0, 0]

arduino = bridgeclient()
print("BridgeClient initiated\n")

server = OSCServer(("0.0.0.0", 10023))

def drawFrameCallback(path, tags, args, source):
    frameArray = [args[0], args[1], args[2], args [3], args[4], args[5]]
    print("Received frame from OSC client ", frameArray)
    
    frameString = "Hello World"
    arduino.put("frame", (frameString))
    print("Sent frame to Arduino          ", frameString)
    
server.addMsgHandler( "/crocoled/drawFrame", drawFrameCallback )
    
print("OSCServer started, CTRL-C to quit")

try:
    while True:
        # Wait for client to send a frame
        server.handle_request();
        
except KeyboardInterrupt:
    print("\nShutting down OSC server")
    server.close()
