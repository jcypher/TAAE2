//
//  AEMeteringModule.m
//  TheAmazingAudioEngine
//
//  Created on 4/06/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//

#import "AEMeteringModule.h"
#import <Accelerate/Accelerate.h>

@implementation AEMeteringModule {
    unsigned int _numChannels;
    float * _averages;
    float * _peaks;
}

- (instancetype _Nullable)initWithRenderer:(AERenderer * _Nonnull)renderer {
    return [self initWithRenderer:renderer numberOfChannels:renderer.outputChannels];
}

- (instancetype _Nullable)initWithRenderer:(AERenderer *)renderer numberOfChannels:(unsigned int)channelCount {
    if ( channelCount < 1 || !(self = [super initWithRenderer:renderer]) ) return nil;
    _numChannels = channelCount;
    _averages = calloc(_numChannels, sizeof(float));
    _peaks = calloc(_numChannels, sizeof(float));
    self.processFunction = AEMeteringModuleProcess;
    return self;
}

- (void)dealloc {
    free(_averages);
    free(_peaks);
}

- (double)averagePowerForChannel:(unsigned int)channelIndex {
    return (double)( channelIndex >= _numChannels ? 0.0 : _averages[channelIndex] );
}

- (double)peakPowerForChannel:(unsigned int)channelIndex {
    return (double)( channelIndex >= _numChannels ? 0.0 : _peaks[channelIndex] );
}

static void AEMeteringModuleProcess(__unsafe_unretained AEMeteringModule * THIS,
                                    const AERenderContext * _Nonnull context) {
    const AudioBufferList * abl = AEBufferStackGet(context->stack, 0);
    if ( !abl ) return;
    float avg, peak;
    unsigned int numChannels = (abl->mNumberBuffers > THIS->_numChannels) ? THIS->_numChannels : abl->mNumberBuffers;
    for ( unsigned int i = 0; i < numChannels; ++i ) {
        avg = 0.0f, peak = 0.0f;
        vDSP_meamgv((float*)abl->mBuffers[i].mData, 1, &avg,  context->frames);
        vDSP_maxmgv((float*)abl->mBuffers[i].mData, 1, &peak, context->frames);
        THIS->_peaks[i] = peak;
        THIS->_averages[i] = avg;
    }
}

@end
