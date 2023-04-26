#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

#if ! JUCE_IOS

//==============================================================================
/**
*/
class PAPUAudioProcessorEditor  : public gin::ProcessorEditor
{
public:
    PAPUAudioProcessorEditor (PAPUAudioProcessor&); //Reference ==> 528 gin_plugineditor.cpp 
    ~PAPUAudioProcessorEditor() override;

    //==============================================================================
    void resized() override; //override perché già presenti nella classe da cui eredita
    void paint (juce::Graphics& g) override; //stessa cosa di sopra

    PAPUAudioProcessor& proc; //definizione di un puntatore alla classe PAPUAudioProcessor
    
    gin::TriggeredScope scope { proc.fifo }; //definizione dello scope nella gui, con proc.fifo che è il buffer da cui legge.
    
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PAPUAudioProcessorEditor)
};

#endif
