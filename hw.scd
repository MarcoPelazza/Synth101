//PHASER
(
SynthDef(\myphaser, {
  arg depth=0.5, mod_freq=0.6;

  var input, output, phased_input;
  var output_bus=0, input_bus=0;

  var num=4;

  input = SoundIn.ar(input_bus);

  phased_input=input;
  while({num>0},{
  phased_input = AllpassC.ar(phased_input, 2, SinOsc.kr(mod_freq, 0, 0.0015,0.005), 0, 1);num=num-1});

  output = Mix.ar([input,phased_input*depth]);
    Out.ar([output_bus, output_bus+1], output);
}).add;
)

//FLANGER
(
SynthDef("flanger", {
	arg ampLFO = 0.0025, freqLFO = 1.5, gff = 1, gfb = 0.1;

	//var maxfreq=5; //ho davvero bisogno di una variabile per questo?


	var maxdelay=0.01; //ho davvero bisogno di una variabile per questo?
	var signal_x;
	var myLFO;
	var signal_x_delayed;
	var out;
	var maxdepth, basedelay;

	basedelay=maxdelay/2;
	//maxdepth=basedelay/2;
	//ampLFO = MouseY.kr(0,maxdepth); //mettilo su una knob
	//freqLFO = MouseX.kr(0,maxfreq); //mettilo su una knob

	myLFO = SinOsc.ar(freqLFO,mul:ampLFO);

	signal_x = SoundIn.ar(0);
	signal_x_delayed = DelayC.ar(signal_x, maxdelay,basedelay+ myLFO);
	signal_x = Mix.ar([SoundIn.ar(0,mul:1), signal_x_delayed*(gfb)]);
	out = Mix.ar([signal_x_delayed*gff,signal_x]);
	Out.ar([0,1],out);
}).add;
)

//WAHWAH
(
SynthDef(\wahWah,{
	arg dur = 1.0, fw = 350, busIn;
	var bpf, e, lpf, out, mix, in,volume=1; //fw => wah frequency
	e = Env([1,6.28,1], [dur/2,dur/2]);
	in = In.ar(busIn,1);
	bpf = BPF.ar(in, fw*EnvGen.kr(e,SinOsc.kr(1/dur))); //Capire se far variare anche lo larghezza della banda
	mix = Mix.ar([in,2*bpf]);
	out = volume*LPF.ar(mix,10000);
	Out.ar(0,[out,out]);
}).send(s);

//Prova inserimento Voce
SynthDef(\voiceIn,{
	arg bus;
	var sig, out;
	sig = SoundIn.ar(0,1);
	out = LPF.ar(sig, 2000);
	Out.ar(bus, out);
}).send(s);

b = Bus.audio(s,1);
x = Synth.new(\voiceIn, [\bus, b]);
y = Synth.after(x, \wahWah, [\busIn, b]);
)



/////////GUI

(
var aSynth, window, button, wid, to, synth=y;

var view, view2, view3, width, top, phaser,flanger,whawha;
~size = 600;
~w = Window("Flow layout example", Rect(200, 200, 800, 500)).front;
~w.background_(Color.cyan);
//~margin = 10;
//~gap = 10;



width = ((800/3)-180).trunc; // Truncate to prevent rounding up half pixels
top = (25);
view = CompositeView(~w, Rect(80, top, 180, 450));
view.background_(Color.grey(0.7));
phaser = StaticText(view, Rect(45, 7, 90, 45));
phaser.background = Color.new255(233, 150, 122);
phaser.string_("PHASER");
phaser.font = Font("Arial", 18);
phaser.align_(\center);

p=Synth.new(\myphaser);
//44
view2= CompositeView(~w, Rect(80+180+50, top, 180, 450));
view2.background_(Color.red(0.4));
flanger = StaticText(view2, Rect(45, 7, 90, 45));
flanger.background = Color.new255(233, 150, 122);
flanger.string_("FLANGER");
flanger.font = Font("Arial", 18);
flanger.align_(\center);

view3=CompositeView(~w, Rect(540, top, 180, 450));
view3.background_(Color.green(0.4));
whawha = StaticText(view3, Rect(45, 7, 90, 45));
whawha.background = Color.new255(233, 150, 122);
whawha.string_("WAH-WAH");
whawha.font = Font("Arial", 18);
whawha.align_(\center);

//devo accorciare la larhezza del riquadro dove indica il valore

//GUI PHASER


d=ControlSpec.new(0.2,1,\lin);
~knobFreq=EZKnob.new(view, Rect(100,60,70,90), nil , d, labelWidth:0, labelHeight:0);
~knobFreq.action_({
            arg knobFreq;
            p.set(\mod_freq, knobFreq.value);
});


//~knobGain=EZKnob.new(view,Rect(20,180,70,90),"gain",i,initVal:0.2,unitWidth:20,layout:\vert2, margin: m);
//~knobGain.action_({
//             arg knobGain;
//             f.set(\output_gain, knobGain.value);
//});

/*j=ControlSpec.new(0,10,\lin);
~knobDelay=EZKnob.new(view,Rect(100,180,70,90),"delay",j,initVal:0.01,unitWidth:20,layout:\vert2, margin: m);
~knobDelay.action_({
			arg knobDelay;
			f.set(\maxdelaytime,knobDelay.value);
});

~knobDecay=EZKnob.new(view,Rect(20,310,70,90),"decay",initVal:0,unitWidth:20,layout:\vert2, margin: m);
~knobDecay.action_({
			arg knobDecay;
			f.set(\decaytime,knobDecay.value);
});
*/
k=ControlSpec.new(0,1,\lin);
~knobDepth=EZKnob.new(view, Rect(100,310,70,90), nil , k, labelWidth:0, labelHeight:0);

~knobDepth.action_({
			arg knobDepth;
             p.set(\depth, knobDepth.value);
});


~buttonp= Button(view,Rect(20,90,50,30)).states_([
             ["OFF",Color.black,Color.gray(0.8)],
             ["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({ arg me;
	var val = me.value;
	if (val == 1)
	{ p.run(false)}{p.run}});

///////////////////////////////////////////

//GUI FLANGER

g = ControlSpec.new(0, 0.005, \lin);
f = ControlSpec.new(0, 3, \lin);
//v = ControlSpec.new(0, 3, \lin);
//l = ControlSpec.new(0, 10, \lin);
//b = ControlSpec.new(0, 2, \lin);

aSynth = Synth(\flanger);

~knobAmp = EZKnob.new(view2, Rect(100,60,70,90), nil , g, labelWidth:0, labelHeight:0);
~knobFre = EZKnob.new(view2, Rect(20,180,70,90), nil , f, labelWidth:0, labelHeight:0);
//~knobVol = EZKnob.new(view2, Rect(100,180,70,90), label:"vol", controlSpec:v, initVal:1);
//~knobGff = EZKnob.new(view2, Rect(20,310,70,90), label:"gff", controlSpec:l, initVal:2);
//~knobGfb = EZKnob.new(view2, Rect(100,310,70,90), label:"gfb", controlSpec:b, initVal:0.5);

~buttonF = Button.new(view2, Rect(40, 90, 50, 30));
~buttonF.states = [[ "stop", Color.black ], ["start", Color.red]];

~knobAmp.action_({arg me; aSynth.set(\ampLFO, me.value)});
~knobFre.action_({arg me; aSynth.set(\freqLFO, me.value) });
//~knobVol.action_({arg me; aSynth.set(\volume, me.value) });
//~knobGff.action_({arg me; aSynth.set(\gff, me.value) });
//~knobGfb.action_({arg me; aSynth.set(\gfb, me.value) });

~buttonF.action_({ arg me;

	var val = me.value;
	if (val == 1)
	{ aSynth.run(false)}{aSynth.run}});

///////////////////////////////////////////////

//GUI WAH WAH
~knobDur = EZKnob.new(view3, Rect(30,150,110,110),"dur",initVal:0.25);
~knobFreq = EZKnob.new(view3, Rect(30,300,110,110),"freq",initVal:0.3);

~buttonW = Button.new(view3, Rect(30,70,50,50));
~buttonW.states = [["stop", Color.black], ["start", Color.red]];
~buttonW.action = ({
	arg me;
	var val = me.value.postln;
	if(val == 1){synth.run(false)}{synth.run}});
~knobDur.action_({
	arg me;
	synth.set(\dur, me.value);
});
~knobFreq.action_({
		arg me;
		synth.set(\fw, me.value);
});

~w.front;
~w.onClose_({CmdPeriod.run});
)