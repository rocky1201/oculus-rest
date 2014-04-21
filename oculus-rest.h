//
//  oculus-rest.h
//  oculus-rest
//
//  Created by Ongkowidjojo, Rocky on 4/21/14.
//  Copyright (c) 2014 Per-Olov Jernberg. All rights reserved.
//
#ifndef oculus_rest_oculus_rest_h
#define oculus_rest_oculus_rest_h

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <microhttpd.h>
#include <OVR.h>

using namespace OVR;

Ptr<DeviceManager>      pManager;
Ptr<HMDDevice>          pHMD;
Ptr<SensorDevice>       pSensor;
SensorFusion*           pFusionResult;
HMDInfo			Info;
bool			InfoLoaded;

#endif
