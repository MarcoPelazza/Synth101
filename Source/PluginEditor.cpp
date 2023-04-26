#include "PluginProcessor.h"
#include "PluginEditor.h"
#include "BinaryData.h"

#if ! JUCE_IOS

//==============================================================================
PAPUAudioProcessorEditor::PAPUAudioProcessorEditor (PAPUAudioProcessor& p)
  : ProcessorEditor (p), proc (p)
{
    additionalProgramming = "Shay Green"; //attributo della classe ProcessEditor da cui questa eredita definisce se per caso ci fosse un altro programmatore (REFERENCE ==> 604 plugineditor.cpp di gin)
    
    addAndMakeVisible (&scope); //rende visibile lo scope
    
    for (auto pp : p.getPluginParameters())//funzione che restituisce un juce::Array di parametri gin::Parameter
    {
        gin::ParamComponent* c;
        if (pp->getUid().contains ("tune") || pp->getUid().contains ("fine") || pp->getUid().contains ("sweep")) //viene usata la freccia perché pp è un puntatore e dunque non può essere usato il punto
            //getUid restituisce una juce::String che indica l'ID del parametro
            c = new gin::Knob (pp, true); //fromcentre = true perché di default e false, controllato in gin::Knob. Tutto i paramentri che devono essere utilizzati per il knob arrivano dalla variabile pp che è un puntatore ad un gin::Parameter che al suo interno ha tutto quello che serve per inizializzare la knob
        else
            c = pp->isOnOff() ? (gin::ParamComponent*)new gin::Switch (pp) : (gin::ParamComponent*)new gin::Knob (pp); 
        //? ==> se il primo è vero si fa la prima azione, se è falso si fa la seconda
        
        addAndMakeVisible (c);
        controls.add (c); //vettore di tutti i controlli presenti nell'interfaccia REFERENCE 137 plugedito.h
    }
    
    setGridSize (13, 3); //metodo di gin::ProcessorEditorBase che setta in che modo organizzzare il grid dell'interfaccia
    
    scope.setNumSamplesPerPixel (2);
    scope.setVerticalZoomFactor (3.0f);
    scope.setColour (gin::TriggeredScope::lineColourId, findColour (gin::PluginLookAndFeel::grey45ColourId));
    scope.setColour (gin::TriggeredScope::traceColourId + 0, findColour (gin::PluginLookAndFeel::accentColourId));
    scope.setColour (gin::TriggeredScope::envelopeColourId + 0, juce::Colours::transparentBlack);
    scope.setColour (gin::TriggeredScope::traceColourId + 1, findColour (gin::PluginLookAndFeel::accentColourId));
    scope.setColour (gin::TriggeredScope::envelopeColourId + 1, juce::Colours::transparentBlack);
}

PAPUAudioProcessorEditor::~PAPUAudioProcessorEditor()//distruttore
{
}

//==============================================================================
void PAPUAudioProcessorEditor::paint (juce::Graphics& g)
{
    ProcessorEditor::paint (g);//verrà poi probabilmente richiamata
}

void PAPUAudioProcessorEditor::resized()
{
    ProcessorEditor::resized();
    // il for più esterno indica le righe in tutti e tre  i casi
    
    for (int i = 0; i < 9; i++) //prima riga
    {
        auto c = controls[i];
        if (i == 0)
            c->setBounds (getGridArea (0, 0).removeFromTop (cy / 2).translated (0, 7));
        else if (i == 1)
            c->setBounds (getGridArea (0, 0).removeFromBottom (cy / 2));
        else
            c->setBounds (getGridArea (i - 1, 0));
        std::cout << c->getUid();
    }
    for (int i = 0; i < 7; i++)//seconda riga
    {
        auto c = controls[i + 9];
        if (i == 0) //tasto on
            c->setBounds (getGridArea (0, 1).removeFromTop (cy / 2).translated (0, 7));//setBounds è ereditato da juce perché la classe ParamsComponent di gin eredita da Component di juce
        else if (i == 1) //tasto off
            c->setBounds (getGridArea (0, 1).removeFromBottom (cy / 2));
        else //knob
            c->setBounds (getGridArea (i - 1, 1));
    }
    for (int i = 0; i < 7; i++)//terza riga
    {
        auto c = controls[i + 9 + 7];
        if (i == 0)
            c->setBounds (getGridArea (0, 2).removeFromTop (cy / 2).translated (0, 7));
        else if (i == 1)
            c->setBounds (getGridArea (0, 2).removeFromBottom (cy / 2));
        else
            c->setBounds (getGridArea (i - 1, 2));
    }

    int n = controls.size();

    controls[n - 1]->setBounds (getGridArea (7, 1));
    controls[n - 2]->setBounds (getGridArea (7, 2));
    
    scope.setBounds (getGridArea (8, 0, 5, 3).reduced (5));
}

#endif
