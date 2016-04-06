//
//  AEMeteringModule.m
//  TheAmazingAudioEngine
//
//  Created on 4/06/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//

#import "AEMeteringModule.h"
#import <Accelerate/Accelerate.h>

@import AudioToolbox;

@implementation AEMeteringModule {
    double _lastAvgPower[2];
    double _lastPeakPower[2];
}

- (instancetype)initWithRenderer:(AERenderer *)renderer {
    if ( !(self = [super initWithRenderer:renderer]) ) return nil;
    self.processFunction = AEMeteringModuleProcess;
    return self;
}

- (double)avgPowerLeft {
    return _lastAvgPower[0];
}

- (double)avgPowerRight {
    return _lastAvgPower[1];
}

- (double)peakPowerLeft {
    return _lastPeakPower[0];
}

- (double)peakPowerRight {
    return _lastPeakPower[1];
}

static void AEMeteringModuleProcess(__unsafe_unretained AEMeteringModule * THIS,
                                        const AERenderContext * _Nonnull context) {
    const AudioBufferList * abl = AEBufferStackGet(context->stack, 0);
    if ( !abl ) return;
    // Get "Stereo" peak and average (channels 0 and 1 assumed for this)
    float avg,  avgL  = 0.0f, avgR  = 0.0f;
    float peak, peakL = 0.0f, peakR = 0.0f;
    for ( int i=0; i < abl->mNumberBuffers; i++ ) {
        // "Left" Channel
        avg = peak = 0.0f;
        vDSP_meamgv((float*)abl->mBuffers[i].mData, 1, &avg,  context->frames);
        vDSP_maxmgv((float*)abl->mBuffers[i].mData, 1, &peak, context->frames);
        if ( peak > peakL ) peakL = peak;
        avgL += avg;
        
        // "Right" Channel
        if ( abl->mBuffers[i].mNumberChannels > 1) {
            avg = peak = 0.0f;
            vDSP_meamgv((float*)abl->mBuffers[i].mData, 1, &avg,  context->frames);
            vDSP_maxmgv((float*)abl->mBuffers[i].mData, 1, &peak, context->frames);
        }
        if ( peak > peakR ) peakR = peak;
        avgR += avg;
    }
    THIS->_lastPeakPower[0] = peakL;
    THIS->_lastPeakPower[1] = peakR;
    THIS->_lastAvgPower[0]  = avgL / ((float)abl->mNumberBuffers);
    THIS->_lastAvgPower[1]  = avgR / ((float)abl->mNumberBuffers);
}

@end

