

(
s.boot;
s.latency = 0.01;
)

//PHASER
(
~pedalOrder=[0,1,2]; //phaser=0 , flager=1 , wah wah=2
~bin = Bus.audio(s);
~b1 = Bus.audio(s);
~b2= Bus.audio(s);
~bout= Bus.audio(s,2);

SynthDef(\myphaser, {
	arg depth=0.5, mod_freq=0.6,input_bus, output_bus, bypass=1;
	var input, output, phased_input;
	var num=4;

	input=In.ar(input_bus);

	if (bypass==0,{
		phased_input=input;
		while({num>0},{
			phased_input = AllpassC.ar(phased_input, 2, SinOsc.kr(mod_freq, 0, 0.0015,0.005), 0, 1);num=num-1});

		output = Mix.ar([input,phased_input*depth]);
	},{output=input;});

	Out.ar(output_bus,output);
	if(~pedalOrder.indexOf(0)==2,{Out.ar([0,1],In.ar(output_bus));},{});

}).add;




SynthDef(\flanger, {

	arg ampLFO = 0.0025, freqLFO = 1.5, input_bus, output_bus, bypass=1;
	var gff=1, gfb=0.1, maxdelay=0.01;

	var signal_x,signal_x_delayed, output;
	var myLFO, maxdepth, basedelay;

	signal_x=In.ar(input_bus);


	if (bypass==0,{

		basedelay=maxdelay/2;
		myLFO = SinOsc.kr(freqLFO,mul:ampLFO);

		//PROCESS

		signal_x_delayed = DelayC.ar(signal_x, maxdelay,basedelay+ myLFO);
		signal_x = Mix.ar([signal_x, signal_x_delayed*(gfb)]);
		output = Mix.ar([signal_x_delayed*gff,signal_x]);
	},{output=signal_x;});

	Out.ar(output_bus,output);
	if(~pedalOrder.indexOf(1)==2,{Out.ar([0,1],In.ar(output_bus));},{});

	//Out.ar(output_bus,output);
	//if(last,{Out.ar([0,1], In.ar(output_bus));},{});
	//Out.ar([0,1], In.ar(output_bus));
}).add;




SynthDef(\wahWah,{
	arg dur = 0.5, amount = 2,input_bus, output_bus, bypass=1;
	var bpf, e, lpf, input, output, mix, fw = 350; //fw => wah frequency


	input=In.ar(input_bus);

	if (bypass==0,{

		e = Env([1,6.28,1], [dur/2,dur/2]);
		//input=In.ar(busIn,1);
		bpf = BPF.ar(input, fw*EnvGen.kr(e,SinOsc.kr(1/dur)));
		mix = Mix.ar([input,amount*bpf]);
		output = LPF.ar(mix,10000);
	},{output=input;});

	Out.ar(output_bus,output);
	if(~pedalOrder.indexOf(2)==2,{Out.ar([0,1],In.ar(output_bus));},{});


}).add;
)


x=Synth(\myphaser);
x=Synth(\flanger);
x=Synth(\wahWah);






(
var mybutton, mybutton2; //buttons that switch the order of the pedals
var phaser, flanger, wahwah; //these are the labels on the top of the pedals
var view, view2, view3; //Pedal interfaces

var durwah, amountwah;
var top, case;
var wahSynth, fSynth;
//var width;
var firstInputChannel=s.options.numOutputBusChannels;
~size = 600;
w = Window("Flow layout example", Rect(0, 0, 1200, 700), false).front;//window non resizable
w.background_(Color.new(128,128,128));
~margin = 10;
~gap = 10;
~phaserGroup=Group.new;//0
~flangerGroup=Group.after(~phaserGroup); //1
~wahGroup=Group.after(~flangerGroup); //2
~pedalOrder=[0,1,2];

w.background_(Color.grey);
w.drawFunc = {
	Pen.fillRect(Rect(0, 0, 1200, 720));
	Pen.fillColor = Color.grey;
	Pen.fillRect(Rect(5, 5, 1190, 690));
	Pen.fillColor = Color.black;
	Pen.fillRect(Rect(105, top-5, 190, 430));
	Pen.fillRect(Rect(505, top-5, 190, 430));
	Pen.fillRect(Rect(905, top-5, 190, 430));

};


//width = ((700/3)-180).trunc; // Truncate to prevent rounding up half pixels
top = (20);
view = CompositeView(w, Rect(110, top, 180, 420));
view.background = Color.new255(245.0,124.0,47.0);
phaser = StaticText(view, Rect(22, 7, 95, 45));

phaser.background = Color.new255(233, 150, 122);
phaser.string_("PHASER");
phaser.font = Font("Arial", 16);
phaser.align_(\center);


view2= CompositeView(w, Rect(510, top, 180, 420));
view2.background_(Color.new255(235,179,38));
flanger = StaticText(view2, Rect(22, 7, 95, 45));
flanger.background = Color.new255(233, 150, 122);
flanger.string_("FLANGER");
flanger.font = Font("Arial", 16);
flanger.align_(\center);

view3=CompositeView(w, Rect(910, top, 180, 420));
view3.background_(Color.new255(227,223,11));
wahwah = StaticText(view3, Rect(22, 7, 95, 45));
wahwah.background = Color.new255(233, 150, 122);
wahwah.string_("WAH-WAH");
wahwah.font = Font("Arial", 16);
wahwah.align_(\center);

//nomi knobs
durwah = StaticText(view3, Rect(50,120,100,100));
durwah.background = (Color.new255(227,223,11));
durwah.string_("frequency");
durwah.stringColor_(Color.black);
durwah.font = Font("Monaco", 23);
durwah.align_(\center);


//definizione synth
p = Synth(\myphaser,[\input_bus, firstInputChannel, \output_bus,~b1],target:~phaserGroup);


fSynth = Synth(\flanger,[\input_bus, ~b1, \output_bus,~b2],target:~flangerGroup);


wahSynth = Synth(\wahWah,[\input_bus, ~b2, \output_bus,~bout.index],target:~wahGroup);



//devo accorciare la larghezza del riquadro dove indica il valore

i=ControlSpec.new(0.2,1,\lin);
~knobFreqp=EZKnob.new(view,Rect(15,140,60,60),nil,i,initVal:0.6,labelWidth:0, labelHeight:0);
~knobFreqp.action_({
	arg me;
	p.set(\mod_freq, me.value);
});

d=ControlSpec.new(0,1,\lin);
~knobDepthp=EZKnob.new(view,Rect(110,280,60,60),nil,d,initVal:0.5,labelWidth:0, labelHeight:0);

~knobDepthp.action_({arg me; p.set(\depth, me.value)});

~buttonp= Button(view,Rect(65,355,50,30)).states_([
	["OFF",Color.black,Color.gray(0.8)],
	["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
	arg me;
	var val = me.value;
	if (val == 0)
	{p.set(\bypass,1)}{p.set(\bypass,0)}});




///////////////////////////////////////////FLANGER


g = ControlSpec.new(0, 0.005, \lin);
f = ControlSpec.new(0, 3, \lin);



~knobAmpf = EZKnob.new(view2, Rect(15,140,60,60), nil, controlSpec:g, initVal:0.0025,labelWidth:0, labelHeight:0);//AMP
~knobFreqf = EZKnob.new(view2, Rect(110,280,60,60), nil, controlSpec:f, initVal:1.5,labelWidth:0, labelHeight:0);//FREQ

~knobAmpf.action_({arg me; fSynth.set(\ampLFO, me.value) });
~knobFreqf.action_({arg me; fSynth.set(\freqLFO, me.value) });

~buttonf= Button(view2,Rect(65,355,50,30)).states_([
	["OFF",Color.black,Color.gray(0.8)],
	["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
	arg me;
	var val = me.value;
	if (val == 0)
	{fSynth.set(\bypass,1)}{fSynth.set(\bypass,0)}});










/////////////////////////////////////////////// WAH WAH


q = ControlSpec.new(2.0,0.5, 'lin', 0.1);
u = ControlSpec.new(0.5, 8, 'lin', 0.5);
~knobDurw = EZKnob.new(view3, Rect(15,140,60,60),nil,q,initVal:0.5, labelWidth:0, labelHeight:0);//dur
~knobAmountw = EZKnob.new(view3, Rect(110,280,60,60),nil,u, initVal:0.5, labelWidth:0, labelHeight:0);//amount
~knobDurw.action_({arg me; wahSynth.set(\dur, me.value)});
~knobAmountw.action_({arg me; wahSynth.set(\amount, me.value)});

~buttonw= Button(view3,Rect(65,355,50,30)).states_([
	["OFF",Color.black,Color.gray(0.8)],
	["ON",Color.red,Color(0.2,0.75,0.95)]
]).font_(Font("Monaco",18)).action_({
	arg me;
	var val = me.value;
	if (val == 0)
		{wahSynth.set(\bypass,1)}{wahSynth.set(\bypass,0)}});

//TRASLAZIONE DELLA GUI






//PRIMO BOTTONEEEEEEEEEEE

mybutton = Button(w, Rect(350, 185, 100, 100));

mybutton.states = [["SWITCH!", Color.black, Color.white], ["SWITCH!", Color.white, Color.black]];

mybutton.action = {
	if((~pedalOrder[0]==0).and(~pedalOrder[1]==1),{case=0},{});//phaser and flanger
	if((~pedalOrder[0]==1).and(~pedalOrder[1]==0),{case=1},{});//flanger and phaser

	if((~pedalOrder[0]==0).and(~pedalOrder[1]==2),{case=2},{});//phaser and wah wah
	if((~pedalOrder[0]==2).and(~pedalOrder[1]==0),{case=3},{});//wah wah and phaser

	if((~pedalOrder[0]==1).and(~pedalOrder[1]==2),{case=4},{});//flanger and wah wah
	if((~pedalOrder[0]==2).and(~pedalOrder[1]==1),{case=5},{});//wah wah and flanger

	//phaser and flanger switch, the new configuration becomes FPW
	if (case==0,{
		view2.moveTo(110, top);
		view.moveTo(510, top);

		//~phaserGroup.moveAfter(~flangerGroup);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~flangerGroup=Group.new;//1
		~phaserGroup=Group.after(~flangerGroup); //0
		~wahGroup=Group.after(~phaserGroup); //2

		// ~freqLFOfSynth=~knobFreqf.value;
		// ~ampLFOfSynth=~knobAmpf.value;

		//~freqLFOfSynth=fSynth.get(\freqLFO);
		//~ampLFOfSynth=fSynth.get(\ampLFO);
		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value],
			target:~wahGroup);



	},{});
	//flanger and phaser switch, the new configuration becomes PFW
	if (case==1,{
		view.moveTo(110, top);
		view2.moveTo(510, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~phaserGroup=Group.new;//0
		~flangerGroup=Group.after(~phaserGroup); //1
		~wahGroup=Group.after(~flangerGroup); //2



		p = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);

	},{});

	//phaser and wah wah switch, the new configuration becomes WPF
	if (case==2,{
		view3.moveTo(110, top);
		view.moveTo(510, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~wahGroup=Group.new;//2
		~phaserGroup=Group.after(~wahGroup); //0
		~flangerGroup=Group.after(~phaserGroup); //1

		wahSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);

	},{});
	//wah wah and phaser switch, the new configuration becomes PWF
	if (case==3,{
		view.moveTo(110, top);
		view3.moveTo(510, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~phaserGroup=Group.new;//2
		~wahGroup=Group.after(~phaserGroup); //0
		~flangerGroup=Group.after(~wahGroup); //1

		p = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);

	},{});

	//flanger and wah wah switch, the new configuration becomes WFP
	if (case==4,{
		view3.moveTo(110, top);
		view2.moveTo(510, top);


		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~wahGroup=Group.new;//2
		~flangerGroup=Group.after(~wahGroup); //0
		~phaserGroup=Group.after(~flangerGroup); //1


		wahSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
	},{});
	//wah wah and flanger switch, the new configuration becomes FWP
	if (case==5,{
		view2.moveTo(110, top);
		view3.moveTo(510, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~flangerGroup=Group.new;//2
		~wahGroup=Group.after(~flangerhGroup); //0
		~phaserGroup=Group.after(~wahGroup); //1


		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
	},{});

	~pedalOrder.swap(0, 1);
};





//SECONDO BOTTONEEEEEEEEEEE

mybutton2 = Button(w, Rect(750, 185, 100, 100));

mybutton2.states = [["SWITCH!"]];



mybutton2.action = {

	if((~pedalOrder[1]==0).and(~pedalOrder[2]==1),{case=0},{});//phaser and flanger
	if((~pedalOrder[1]==1).and(~pedalOrder[2]==0),{case=1},{});//flanger and phaser

	if((~pedalOrder[1]==0).and(~pedalOrder[2]==2),{case=2},{});//phaser and wah wah
	if((~pedalOrder[1]==2).and(~pedalOrder[2]==0),{case=3},{});//wah wah and phaser

	if((~pedalOrder[1]==1).and(~pedalOrder[2]==2),{case=4},{});//flanger and wah wah
	if((~pedalOrder[1]==2).and(~pedalOrder[2]==1),{case=5},{});//wah wah and flanger

	//phaser and flanger switch, the new configuration becomes WFP
	if (case==0,{
		view2.moveTo(510, top);
		view.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~wahGroup=Group.new;//2
		~flangerGroup=Group.after(~wahGroup); //0
		~phaserGroup=Group.after(~flangerGroup); //1


		wahSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
	},{});
	//flanger and phaser switch, the new configuration becomes WPF
	if (case==1,{
		view.moveTo(510, top);
		view2.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~wahGroup=Group.new;//2
		~phaserGroup=Group.after(~wahGroup); //0
		~flangerGroup=Group.after(~phaserGroup); //1

		wahSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
	},{});

	//phaser and wah wah switch, the new configuration becomes FWP
	if (case==2,{
		view3.moveTo(510, top);
		view.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~flangerGroup=Group.new;//2
		~wahGroup=Group.after(~flangerhGroup); //0
		~phaserGroup=Group.after(~wahGroup); //1


		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
	},{});
	//wah wah and phaser switch, the new configuration becomes FPW
	if (case==3,{
		view.moveTo(510, top);
		view3.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~flangerGroup=Group.new;//1
		~phaserGroup=Group.after(~flangerGroup); //0
		~wahGroup=Group.after(~phaserGroup); //2

		// ~freqLFOfSynth=~knobFreqf.value;
		// ~ampLFOfSynth=~knobAmpf.value;

		//~freqLFOfSynth=fSynth.get(\freqLFO);
		//~ampLFOfSynth=fSynth.get(\ampLFO);
		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		p = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value],
			target:~wahGroup);
	},{});

	//flanger and wah wah switch, the new configuration becomes PWF
	if (case==4,{
		view3.moveTo(510, top);
		view2.moveTo(910, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~phaserGroup=Group.new;//2
		~wahGroup=Group.after(~phaserGroup); //0
		~flangerGroup=Group.after(~wahGroup); //1

		p = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
	},{});
	//wah wah and flanger switch, the new configuration becomes PFW
	if (case==5,{
		view2.moveTo(510, top);
		view3.moveTo(910, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~phaserGroup=Group.new;//0
		~flangerGroup=Group.after(~phaserGroup); //1
		~wahGroup=Group.after(~flangerGroup); //2


		p = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypass,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypass,~buttonf.value]
			,target:~flangerGroup);
		wahSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout.index,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypass,~buttonw.value]
			,target:~wahGroup);
	},{});

	~pedalOrder.swap(1, 2);
};



w.front;
w.onClose_({CmdPeriod.run});
)