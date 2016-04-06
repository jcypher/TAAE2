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
    
    // "Left" Channel
    if ( abl->mNumberBuffers > 0 ) {
        float avg  = 0.0f, peak = 0.0f;
        vDSP_meamgv((float*)abl->mBuffers[0].mData, 1, &avg,  context->frames);
        vDSP_maxmgv((float*)abl->mBuffers[0].mData, 1, &peak, context->frames);
        THIS->_lastPeakPower[0] = peak;
        THIS->_lastAvgPower[0] = avg;
    }
    
    // "Right" Channel
    if ( abl->mNumberBuffers > 1 ) {
        float avg  = 0.0f, peak = 0.0f;
        vDSP_meamgv((float*)abl->mBuffers[1].mData, 1, &avg,  context->frames);
        vDSP_maxmgv((float*)abl->mBuffers[1].mData, 1, &peak, context->frames);
        THIS->_lastPeakPower[1] = peak;
        THIS->_lastAvgPower[1] = avg;
    }
}

@end

