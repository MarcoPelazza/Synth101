//PHASER
(
SynthDef(\myphaser, {
  arg depth=1, mod_freq=0.4;

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

(
SynthDef("flanger", {

  arg ampLFO = 0.0025, freqLFO = 1.5;
  var gff=1;
  var gfb=0.1;

  var maxdelay=0.01; //ho davvero bisogno di una variabile per questo?

  var signal_x;

  var myLFO;
  var signal_x_delayed;
  var out;

  var maxdepth, basedelay;

  //////////////

  basedelay=maxdelay/2;
//  maxdepth=basedelay/2;

  myLFO = SinOsc.kr(freqLFO,mul:ampLFO);

  //PROCESS
  signal_x = SoundIn.ar(0);
  signal_x_delayed = DelayC.ar(signal_x, maxdelay,basedelay+ myLFO);
  signal_x = Mix.ar([SoundIn.ar(0,mul:1), signal_x_delayed*(gfb)]);
  out = Mix.ar([signal_x_delayed*gff,signal_x]);
  Out.ar([0,1],out);

}).add;
)


//a = Synth(\flanger);

(
SynthDef(\wahWah,{
  arg dur = 1.0, fw = 350, busIn;
  var bpf, e, lpf, out, mix, in; //fw => wah frequency
  e = Env([1,6.28,1], [dur/2,dur/2]);
  in = In.ar(busIn,1);
  bpf = BPF.ar(in, fw*EnvGen.kr(e,SinOsc.kr(1/dur))); //Capire se far variare anche lo larghezza della banda
  mix = Mix.ar([in,2*bpf]);
  out = LPF.ar(mix,10000);
  Out.ar(0,[out,out]);
}).send(s);


//b = Bus.audio(s,1);
//x = Synth.new(\voiceIn, [\bus, b]);
//y = Synth.after(x, \wahWah, [\busIn, b]);
)







//GESTIONE BUS
SynthDef(\voiceIn,{
  arg bus;
  var sig, out;
  sig = SoundIn.ar(0,1);
  out = LPF.ar(sig, 2000);
  Out.ar(bus, out);
}).send(s);




(
var aSynth, window, button, wid, to, synth=y, mybutton;

var view, view2, view3, width, top, phaser,flanger,whawha, case;

var  pedalOrder=[0,1,2]; //phaser=0 , flager=1 , wah wah=2


~size = 600;
~w = Window("Flow layout example", Rect(0, 0, 1200, 700)).front;
~w.background_(Color.cyan);
~margin = 10;
~gap = 10;



width = ((800/3)-180).trunc; // Truncate to prevent rounding up half pixels
top = (10);
view = CompositeView(~w, Rect(width+48, top, 180, 450));
view.background_(Color.grey(0.7));
phaser = StaticText(view, Rect(22, 7, 95, 45));
phaser.background = Color.new255(233, 150, 122);
phaser.string_("PHASER");
phaser.font = Font("Arial", 16);
phaser.align_(\center);

view2= CompositeView(~w, Rect(width+400+48, top, 180, 450));
view2.background_(Color.red(0.4));
flanger = StaticText(view2, Rect(22, 7, 95, 45));
flanger.background = Color.new255(233, 150, 122);
flanger.string_("FLANGER");
flanger.font = Font("Arial", 16);
flanger.align_(\center);

view3=CompositeView(~w, Rect(width+800+48, top, 180, 450));
view3.background_(Color.green(0.4));
whawha = StaticText(view3, Rect(22, 7, 95, 45));
whawha.background = Color.new255(233, 150, 122);
whawha.string_("WAH-WAH");
whawha.font = Font("Arial", 16);
whawha.align_(\center);

//devo accorciare la larghezza del riquadro dove indica il valore

i=ControlSpec.new(0.2,1,\lin);
~knobFreq=EZKnob.new(view,Rect(100,60,70,90),"freq",i,initVal:0.6,unitWidth:20,layout:\vert2, margin: m);
~knobFreq.action_({
             arg knobFreq;
             f.set(\mod_freq, knobFreq.value);
});

/*
//~knobGain=EZKnob.new(view,Rect(20,180,70,90),"gain",i,initVal:0.2,unitWidth:20,layout:\vert2, margin: m);
//~knobGain.action_({
             arg knobGain;
             f.set(\output_gain, knobGain.value);
});

j=ControlSpec.new(0,10,\lin);
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

d=ControlSpec.new(0,1,\lin);
~knobDepth=EZKnob.new(view,Rect(100,310,70,90),"depth",d,initVal:0.5,unitWidth:20,layout:\vert2, margin: m);

~knobDepth.action_({
      arg knobDepth;
             f.set(\depth, knobDepth.value);
});


~buttonf= Button(view,Rect(20,90,50,30)).states_([
             ["OFF",Color.black,Color.gray(0.8)],
             ["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
             arg obj=0;
             if(obj.value==1,{f=Synth.new(\myphaser)},{f.free});
});





///////////////////////////////////////////FLANGER


g = ControlSpec.new(0, 0.005, \lin);
f = ControlSpec.new(0, 3, \lin);

aSynth = Synth(\flanger);

~knobAmp = EZKnob.new(view2, Rect(40,140,100,100), label:"amp", controlSpec:g, initVal:0.0025);
~knobFre = EZKnob.new(view2, Rect(40,280,100,100), label:"freq", controlSpec:f, initVal:1.5);

~buttonF = Button.new(view2, Rect(40, 90, 50, 30));
~buttonF.states = [[ "stop", Color.black ], ["start", Color.red]];

~knobAmp.action_({arg me; aSynth.set(\ampLFO, me.value) });
~knobFre.action_({arg me; aSynth.set(\freqLFO, me.value) });

~buttonF.action_({ arg me;

  var val = me.value.postln;
  if (val == 1)
  { aSynth.run(false)}{aSynth.run}});












///////////////////////////////////////////////
~knobDur = EZKnob.new(view3, Rect(30,150,110,110),"dur",initVal:0.0025);
~knobDur.valueAction_(0.25);
~knobFreq = EZKnob.new(view3, Rect(30,300,110,110),"freq",initVal:0.0025);
~knobFreq.valueAction_(0.3);
~buttonW = Button.new(view3, Rect(30,70,50,50));
~buttonW.states = [["stop", Color.black], ["start", Color.red]];
~buttonW.action = ({
  arg me;
  var val = me.value.postln;
  if(val == 1){synth.run(false)}{synth.run}});
~knobDur.action_({
  arg me;
  synth.set(\dur, me.value)
});
~knobFreq.action_({
    arg me;
    synth.set(\fw, me.value.linlin(0,1,200,2000,5000));
      me.value.linlin(0,1,200,2000,5000).postln;
});


//TRASLAZIONE DELLA GUI






//PRIMO BOTTONEEEEEEEEEEE
mybutton = Button(~w, Rect(width+48+250, 100, 100, 100));
//mybutton=Button.new(w, Rect(20, 700, 30, 30)).states_([view.moveTo(100, 100),view.moveTo(width+48, top)]).action_({ arg butt;
//	butt.value.postln;});

mybutton.states = [["SWITCH!", Color.black, Color.white], ["SWITCH!", Color.white, Color.black]];



mybutton.action = {

	if((pedalOrder[0]==0).and(pedalOrder[1]==1),{case=0},{});//phaser and flanger
	if((pedalOrder[0]==1).and(pedalOrder[1]==0),{case=1},{});//flanger and phaser

	if((pedalOrder[0]==0).and(pedalOrder[1]==2),{case=2},{});//phaser and wah wah
	if((pedalOrder[0]==2).and(pedalOrder[1]==0),{case=3},{});//wah wah and phaser

	if((pedalOrder[0]==1).and(pedalOrder[1]==2),{case=4},{});//flanger and wah wah
	if((pedalOrder[0]==2).and(pedalOrder[1]==1),{case=5},{});//wah wah and flanger

	//phaser and flanger
	if (case==0,{
		view2.moveTo(width+48, top);
		view.moveTo(width+400+48, top);
	},{});
	//flanger and phaser
    if (case==1,{
		view.moveTo(width+48, top);
		view2.moveTo(width+400+48, top);
	},{});

    //phaser and wah wah
	if (case==2,{
		view3.moveTo(width+48, top);
		view.moveTo(width+400+48, top);
	},{});
	//wah wah and phaser
    if (case==3,{
		view.moveTo(width+48, top);
		view3.moveTo(width+400+48, top);
	},{});

	//flanger and wah wah
    if (case==4,{
		view3.moveTo(width+48, top);
		view2.moveTo(width+400+48, top);
	},{});
	//wah wah and flanger
    if (case==5,{
		view2.moveTo(width+48, top);
		view3.moveTo(width+400+48, top);
	},{});

	pedalOrder.swap(0, 1);
};





//SECONDO BOTTONEEEEEEEEEEE

mybutton = Button(~w, Rect(width+48+650, 100, 100, 100));
//mybutton=Button.new(w, Rect(20, 700, 30, 30)).states_([view.moveTo(100, 100),view.moveTo(width+48, top)]).action_({ arg butt;
//	butt.value.postln;});

mybutton.states = [["SWITCH!"]];



mybutton.action = {

	if((pedalOrder[1]==0).and(pedalOrder[2]==1),{case=0},{});//phaser and flanger
	if((pedalOrder[1]==1).and(pedalOrder[2]==0),{case=1},{});//flanger and phaser

	if((pedalOrder[1]==0).and(pedalOrder[2]==2),{case=2},{});//phaser and wah wah
	if((pedalOrder[1]==2).and(pedalOrder[2]==0),{case=3},{});//wah wah and phaser

	if((pedalOrder[1]==1).and(pedalOrder[2]==2),{case=4},{});//flanger and wah wah
	if((pedalOrder[1]==2).and(pedalOrder[2]==1),{case=5},{});//wah wah and flanger

	//phaser and flanger
	if (case==0,{
		view2.moveTo(width+400+48, top);
		view.moveTo(width+800+48, top);
	},{});
	//flanger and phaser
    if (case==1,{
		view.moveTo(width+400+48, top);
		view2.moveTo(width+800+48, top);
	},{});

    //phaser and wah wah
	if (case==2,{
		view3.moveTo(width+400+48, top);
		view.moveTo(width+800+48, top);
	},{});
	//wah wah and phaser
    if (case==3,{
		view.moveTo(width+400+48, top);
		view3.moveTo(width+800+48, top);
	},{});

	//flanger and wah wah
    if (case==4,{
		view3.moveTo(width+400+48, top);
		view2.moveTo(width+800+48, top);
	},{});
	//wah wah and flanger
    if (case==5,{
		view2.moveTo(width+400+48, top);
		view3.moveTo(width+800+48, top);
	},{});

	pedalOrder.swap(1, 2);
};



~w.front;
~w.onClose_({CmdPeriod.run});
)