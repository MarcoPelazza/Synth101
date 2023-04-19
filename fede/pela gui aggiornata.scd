

(
s.boot;
s.latency = 0.01;
)
(
~pedalOrder=[0,1,2]; //phaser=0 , flager=1 , wah wah=2
~bin = Bus.audio(s);
~b1 = Bus.audio(s);
~b2= Bus.audio(s);
~bout= Bus.audio(s,2);

// Out.ar(~bin,SoundIn.ar(0));
)

//PHASER
(
SynthDef(\myphaser, {
	arg depth=0.5, mod_freq=0.6,input_bus, output_bus;
	var input, output, phased_input;
	var last=false;//dichiarare false qui potrebbe darmi problemi nel collegamento pedali 2 e 3
	//probabilmente bisogna mettere una qualche variabile "isFirst"
	var num=4;

	/*if(~pedalOrder.indexOf(0)==0,{
		Out.ar(~bin,SoundIn.ar(0));input =In.ar(~bin.index);output_bus=((~b1.index));},{});
	if(~pedalOrder.indexOf(0)==1,{input =In.ar(~b1.index);output_bus=((~b2.index));},{});
	if(~pedalOrder.indexOf(0)==2,{input =In.ar(~b2.index);output_bus=((~bout.index));last=true;},{});*/

	input=In.ar(input_bus);

	phased_input=input;
	while({num>0},{
		phased_input = AllpassC.ar(phased_input, 2, SinOsc.kr(mod_freq, 0, 0.0015,0.005), 0, 1);num=num-1});

	output = Mix.ar([input,phased_input*depth]);
	//if(output_bus==0,{Out.ar([output_bus,output_bus+1], output);},{Out.ar(output_bus, output);})
	Out.ar(output_bus,output);
	if(~pedalOrder.indexOf(0)==2,{Out.ar([0,1],In.ar(output_bus));},{});
    //	if(last,{Out.ar([0,1], In.ar(output_bus));},{});
}).add;


SynthDef("flanger", {

	arg ampLFO = 0.0025, freqLFO = 1.5,input_bus, output_bus;
	var gff=1;
	var gfb=0.1;

	var maxdelay=0.01;

	var signal_x,signal_x_delayed, output;
	var myLFO, maxdepth, basedelay;
	var last=false;

	//////////////

	/*if(~pedalOrder.indexOf(1)==0,{
		Out.ar(~bin,SoundIn.ar(0));signal_x =In.ar(~bin.index);output_bus=((~b1.index));},{});
	if(~pedalOrder.indexOf(1)==1,{signal_x =In.ar(~b1.index);output_bus=((~b2.index));},{});
	if(~pedalOrder.indexOf(1)==2,{signal_x =In.ar(~b2.index);output_bus=((~bout.index));last=true;},{});*/



	signal_x=In.ar(input_bus);
	basedelay=maxdelay/2;
	//  maxdepth=basedelay/2;

	myLFO = SinOsc.kr(freqLFO,mul:ampLFO);

	//PROCESS

	signal_x_delayed = DelayC.ar(signal_x, maxdelay,basedelay+ myLFO);
	signal_x = Mix.ar([signal_x, signal_x_delayed*(gfb)]);
	output = Mix.ar([signal_x_delayed*gff,signal_x]);


	//if(output_bus==0,{Out.ar([output_bus,output_bus+1], output);},{Out.ar(output_bus, output);})

	Out.ar(output_bus,output);
	if(~pedalOrder.indexOf(1)==2,{Out.ar([0,1],In.ar(output_bus));},{});

	//Out.ar(output_bus,output);
	//if(last,{Out.ar([0,1], In.ar(output_bus));},{});
	//Out.ar([0,1], In.ar(output_bus));
}).add;




​





SynthDef(\wahWah,{
	arg dur = 0.5,input_bus, output_bus, amount = 2;
	var bpf, e, lpf, output, mix,fw = 350, input,last=false; //fw => wah frequency
/*
	//SystemClock.sched(1.0,{
	if(~pedalOrder.indexOf(2)==0,{
		Out.ar(~bin,SoundIn.ar(0));input =In.ar(~bin.index);output_bus=((~b1.index));},{});
	if(~pedalOrder.indexOf(2)==1,{input =In.ar(~b1.index);output_bus=((~b2.index));},{});
	if(~pedalOrder.indexOf(2)==2,{input =In.ar(~b2.index);output_bus=((~bout.index));last=true;},{});
	//if(~pedalOrder.indexOf(2)==1,{//Out.ar(~bin,SoundIn.ar(0));
		//input =In.ar(~b1.index);output_bus=((~b2.index));last=true;},{});  //TEST FUNCTIONS*/


	input=In.ar(input_bus);
	e = Env([1,6.28,1], [dur/2,dur/2]);
	//input=In.ar(busIn,1);
	bpf = BPF.ar(input, fw*EnvGen.kr(e,SinOsc.kr(1/dur)));
	mix = Mix.ar([input,amount*bpf]);
	output = LPF.ar(mix,10000);

	//if(last,{Out.ar([0,1], output);},{Out.ar(output_bus, output);});
	Out.ar(output_bus,output);
	if(~pedalOrder.indexOf(2)==2,{Out.ar([0,1],In.ar(output_bus));},{});
	//Out.ar([0,1],In.ar(output_bus));



		//});
}).add;
)

x=Synth(\myphaser);
x=Synth(\flanger);
x=Synth(\wahWah);






//GESTIONE BUS
/*SynthDef(\voiceIn,{
  arg bus;
  var sig, out;  sig = SoundIn.ar(0,1);
  out = LPF.ar(sig, 2000);
  Out.ar(bus, out);
}).send(s);
*/




(
var fSynth, window, button, wid, to, synth=y, mybutton;

var view, view2, view3, width, top, phaser, flanger, whawha, case, wahSynth, wahRoutine;

var firstInputChannel=s.options.numOutputBusChannels;
~size = 600;
~w = Window("Flow layout example", Rect(0, 0, 1200, 700), false).front;//window non resizable
~w.background_(Color.cyan);
~margin = 10;
~gap = 10;
~phaserGroup=Group.new;//0
~flangerGroup=Group.after(~phaserGroup); //1
~wahGroup=Group.after(~flangerGroup); //2
~freqLFOfSynth;
~ampLFOfSynth;

/*
~phaserGroup=Group.new;//0
~wahGroup=Group.after(~phaserGroup); //2
~flangerGroup=Group.after(~wahGroup); //1*/



width = ((700/3)-180).trunc; // Truncate to prevent rounding up half pixels
top = (10);
view = CompositeView(~w, Rect(110, top, 180, 450));
view.background_(Color.grey(0.7));

phaser = StaticText(view, Rect(22, 7, 95, 45));
phaser.background = Color.new255(233, 150, 122);
phaser.string_("PHASER");
phaser.font = Font("Arial", 16);
phaser.align_(\center);


view2= CompositeView(~w, Rect(510, top, 180, 450));
view2.background_(Color.red(0.4));
flanger = StaticText(view2, Rect(22, 7, 95, 45));
flanger.background = Color.new255(233, 150, 122);
flanger.string_("FLANGER");
flanger.font = Font("Arial", 16);
flanger.align_(\center);

view3=CompositeView(~w, Rect(910, top, 180, 450));
view3.background_(Color.green(0.4));
whawha = StaticText(view3, Rect(22, 7, 95, 45));
whawha.background = Color.new255(233, 150, 122);
whawha.string_("WAH-WAH");
whawha.font = Font("Arial", 16);
whawha.align_(\center);

//definizione synth
p = Synth(\myphaser,[\input_bus, firstInputChannel, \output_bus,~b1],target:~phaserGroup);
p.run(false);

fSynth = Synth(\flanger,[\input_bus, ~b1, \output_bus,~b2],target:~flangerGroup);
fSynth.run(false);

wahSynth = Synth(\wahWah,[\input_bus, ~b2, \output_bus,~bout.index],target:~wahGroup);
wahSynth.run(false);


//devo accorciare la larghezza del riquadro dove indica il valore

i=ControlSpec.new(0.2,1,\lin);
~knobFreqp=EZKnob.new(view,Rect(40,280,100,100),"freq",i,initVal:0.6,unitWidth:20,layout:\vert2, margin: m);
~knobFreqp.action_({
             arg me;
             p.set(\mod_freq, me.value);
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
~knobDepthp=EZKnob.new(view,Rect(40,140,100,100),"depth",d,initVal:0.5,unitWidth:20,layout:\vert2, margin: m);

~knobDepthp.action_({arg me; p.set(\depth, me.value)});



~buttonp= Button(view,Rect(20,90,50,30)).states_([
             ["OFF",Color.black,Color.gray(0.8)],
             ["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
    arg me;
	var val = me.value;
	if (val == 0)
	{p.run(false)}{p.run(true)}});




///////////////////////////////////////////FLANGER


g = ControlSpec.new(0, 0.005, \lin);
f = ControlSpec.new(0, 3, \lin);



~knobAmpf = EZKnob.new(view2, Rect(40,140,100,100), label:"amp", controlSpec:g, initVal:0.0025);
~knobFreqf = EZKnob.new(view2, Rect(40,280,100,100), label:"freq", controlSpec:f, initVal:1.5);

~knobAmpf.action_({arg me; fSynth.set(\ampLFO, me.value) });
~knobFreqf.action_({arg me; fSynth.set(\freqLFO, me.value) });

~buttonf= Button(view2,Rect(40, 90, 50, 30)).states_([
             ["OFF",Color.black,Color.gray(0.8)],
             ["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
    arg me;
	var val = me.value;
	if (val == 0)
	{fSynth.run(false)}{fSynth.run(true)}});










/////////////////////////////////////////////// WAH WAH


u = ControlSpec.new(0.5, 8, 'lin', 0.5);
q = ControlSpec.new(0.5,2.0, 'lin', 0.1);
~knobDurw = EZKnob.new(view3, Rect(40,140,100,100),"dur",u,initVal:0.5);
~knobAmountw = EZKnob.new(view3, Rect(40,280,100,100),"amount",q, initVal:0.5);
~knobDurw.action_({arg me; wahSynth.set(\dur, me.value)});
~knobAmountw.action_({arg me; wahSynth.set(\amount, me.value)});

~buttonw= Button(view3,Rect(20,90,50,30)).states_([
             ["OFF",Color.black,Color.gray(0.8)],
             ["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
    arg me;
	var val = me.value;
	if (val == 0)
	{wahSynth.run(false)}{wahSynth.run(true)}});

//TRASLAZIONE DELLA GUI






//PRIMO BOTTONEEEEEEEEEEE

mybutton = Button(~w, Rect(width+48+250, 100, 100, 100));
//mybutton=Button.new(w, Rect(20, 700, 30, 30)).states_([view.moveTo(100, 100),view.moveTo(width+48, top)]).action_({ arg butt;
//	butt.value.postln;});

mybutton.states = [["SWITCH!", Color.black, Color.white], ["SWITCH!", Color.white, Color.black]];

mybutton.action = {

	if((~pedalOrder[0]==0).and(~pedalOrder[1]==1),{case=0},{});//phaser and flanger
	if((~pedalOrder[0]==1).and(~pedalOrder[1]==0),{case=1},{});//flanger and phaser

	if((~pedalOrder[0]==0).and(~pedalOrder[1]==2),{case=2},{});//phaser and wah wah
	if((~pedalOrder[0]==2).and(~pedalOrder[1]==0),{case=3},{});//wah wah and phaser

	if((~pedalOrder[0]==1).and(~pedalOrder[1]==2),{case=4},{});//flanger and wah wah
	if((~pedalOrder[0]==2).and(~pedalOrder[1]==1),{case=5},{});//wah wah and flanger

	//phaser and flanger
	if (case==0,{
		view2.moveTo(width+48, top);
		view.moveTo(width+400+48, top);

		//~phaserGroup.moveAfter(~flangerGroup);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~flangerGroup=Group.new;//0
		~phaserGroup=Group.after(~flangerGroup); //1
		~wahGroup=Group.after(~phaserGroup); //2

		// ~freqLFOfSynth=~knobFreqf.value;
		// ~ampLFOfSynth=~knobAmpf.value;

		//~freqLFOfSynth=fSynth.get(\freqLFO);
		//~ampLFOfSynth=fSynth.get(\ampLFO);
		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value]
			,target:~flangerGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value]
			,target:~phaserGroup);
		wahSynth = Synth(\wahWah,[\input_bus, ~b2, \output_bus,~bout.index, \last, true],target:~wahGroup);



	},{});
	//flanger and phaser
    if (case==1,{
		view.moveTo(width+48, top);
		view2.moveTo(width+400+48, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~phaserGroup=Group.new;//0
		~flangerGroup=Group.after(~phaserGroup); //1
		~wahGroup=Group.after(~flangerGroup); //2



		p = Synth(\myphaser,[\input_bus, firstInputChannel, \output_bus,~b1],target:~phaserGroup);
		fSynth = Synth(\flanger,[\input_bus, ~b1, \output_bus,~b2],target:~flangerGroup);
		wahSynth = Synth(\wahWah,[\input_bus, ~b2, \output_bus,~bout.index, \last, true],target:~wahGroup);

	},{});

    //phaser and wah wah
	if (case==2,{
		view3.moveTo(width+48, top);
		view.moveTo(width+400+48, top);
		//~phaserGroup.moveAfter(~wahGroup);
		//~wahGroup
		p.set([\input_bus, ~b1, \output_bus,~b2]);
		wahSynth.set([\input_bus, firstInputChannel, \output_bus,~b1]);
	},{});
	//wah wah and phaser
    if (case==3,{
		view.moveTo(width+48, top);
		view3.moveTo(width+400+48, top);
		~wahGroup.moveAfter(~flangerGroup);
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

	~pedalOrder.swap(0, 1);
};





//SECONDO BOTTONEEEEEEEEEEE

mybutton = Button(~w, Rect(width+48+650, 100, 100, 100));
//mybutton=Button.new(w, Rect(20, 700, 30, 30)).states_([view.moveTo(100, 100),view.moveTo(width+48, top)]).action_({ arg butt;
//	butt.value.postln;});

mybutton.states = [["SWITCH!"]];



mybutton.action = {

	if((~pedalOrder[1]==0).and(~pedalOrder[2]==1),{case=0},{});//phaser and flanger
	if((~pedalOrder[1]==1).and(~pedalOrder[2]==0),{case=1},{});//flanger and phaser

	if((~pedalOrder[1]==0).and(~pedalOrder[2]==2),{case=2},{});//phaser and wah wah
	if((~pedalOrder[1]==2).and(~pedalOrder[2]==0),{case=3},{});//wah wah and phaser

	if((~pedalOrder[1]==1).and(~pedalOrder[2]==2),{case=4},{});//flanger and wah wah
	if((~pedalOrder[1]==2).and(~pedalOrder[2]==1),{case=5},{});//wah wah and flanger

	//phaser and flanger
	if (case==0,{
		view2.moveTo(510, top);
		view.moveTo(910, top);
	},{});
	//flanger and phaser
    if (case==1,{
		view.moveTo(510, top);
		view2.moveTo(910, top);
	},{});

    //phaser and wah wah
	if (case==2,{
		view3.moveTo(510, top);
		view.moveTo(910, top);
	},{});
	//wah wah and phaser
    if (case==3,{
		view.moveTo(510, top);
		view3.moveTo(910, top);
	},{});

	//flanger and wah wah
    if (case==4,{
		view3.moveTo(510, top);
		view2.moveTo(910, top);
		~flangerGroup.moveAfter(~wahGroup);
		fSynth.set([\input_bus, ~b2, \output_bus,~bout]);
		wahSynth.set([\input_bus, ~b1, \output_bus,~b2]);
	},{});
	//wah wah and flanger
    if (case==5,{
		view2.moveTo(510, top);
		view3.moveTo(910, top);
	},{});

	~pedalOrder.swap(1, 2);
};



~w.front;
~w.onClose_({CmdPeriod.run});
)