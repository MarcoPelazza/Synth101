//booting the server to be highly responsive to audio input
(
s.boot;
s.latency = 0.01;
)

//////////////////////////////////////////////DEFINITIONS OF THE 3 EFFECTS
(
~pedalOrder=[0,1,2]; //we need this to keep track of the order of the pedals, initially phaser=0 , flager=1 , wah wah=2
~b1 = Bus.audio(s);
~b2= Bus.audio(s);
~bout= Bus.audio(s,2);
)

(
SynthDef(\myphaser, {
	arg depth=0.5, mod_freq=0.6,input_bus, output_bus, bypassp=0;
	var input, output, phased_input;
	var num=4;

	input=In.ar(input_bus); //read from input bus


	phased_input=input;
	while({num>0},{
		phased_input = AllpassC.ar(phased_input, 2, SinOsc.kr(mod_freq, 0, 0.0015,0.005), 0);num=num-1});


	output=Select.ar(bypassp,[Mix.ar([input,phased_input*depth]),input]); //do you want to bypass this pedal?

	Out.ar(output_bus,output); //write on output bus

}).add;





SynthDef(\flanger, {

	arg ampLFO = 0.0025, freqLFO = 1.5, input_bus, output_bus, bypassf=0;
	var gff=1, gfb=0.1, maxdelay=0.01;

	var signal_x,signal_x_delayed, output;
	var myLFO, maxdepth, basedelay;


	signal_x=In.ar(input_bus);//read from input bus
	basedelay=maxdelay/2;
	myLFO = SinOsc.kr(freqLFO,mul:ampLFO);


	signal_x_delayed = DelayC.ar(signal_x, maxdelay,basedelay+ myLFO);
	signal_x = Mix.ar([signal_x, signal_x_delayed*(gfb)]);
	output = Mix.ar([signal_x_delayed*gff,signal_x]);

	output=Select.ar(bypassf,[Mix.ar([signal_x_delayed*gff,signal_x]),signal_x]);//do you want to bypass this pedal?

	Out.ar(output_bus,output); //write on output bus

}).add;


//f = Synth.new(\flanger,[\input_bus, s.options.numOutputBusChannels, \output_bus,~bout,\bypassf,0]);




SynthDef(\wahWah,{
	arg dur = 0.5, amount = 2,input_bus, output_bus, bypassw=0;
	var bpf, e, lpf, input, output, mix, fw = 350; //fw => wah frequency


	input=In.ar(input_bus); //read from input bus

	e = Env([1,6.28,1], [dur/2,dur/2]);
	bpf = BPF.ar(input, fw*EnvGen.kr(e,SinOsc.kr(1/dur)));
	mix = Mix.ar([input,amount*bpf]);



	output=Select.ar(bypassw,[LPF.ar(mix,10000),input]); //do you want to bypass this pedal?
	Out.ar(output_bus,output); //write on output bus

}).add;




SynthDef(\outputAudioStereo,{ //send audio to the speakers (we use this after the chain of effects)
	Out.ar([0,1],In.ar(~bout));
}).add;

)

//w = Synth(\wahWah,[\input_bus, s.options.numOutputBusChannels, \output_bus,~bout]);







//////////////////////////////////////////////GUI AND BUS IMPLEMENTATION





(
var view1, view2, view3; //Pedal interfaces
var leftSwitchButton, rightSwitchButton; //buttons that switch the order of the pedals

var phaserLabel, flangerLabel, wahwahLabel; //labels on the top of the pedals
var durwahLabel, amountwahLabel; //labels of the knobs of the pedals
var specFreqp,specDepthp,specAmpf,specFreqf,specDurw,specAmountw; //to help us define the limit values of the knobs

var pSynth, fSynth, wSynth, outputAudioStereoSynth; //we'll use these to get the audio of the Synthesizers

var durwah, amountwah;
var freqf, ampf;
var freqp, depthp;

var scopein, scopeout;
var insign, outsign;

var top=20, case; //case will help later in distinguishing the order of the pedals
var firstInputChannel=s.options.numOutputBusChannels;

//Order in which the pedals should initially play:
~phaserGroup=Group.new; //phaser=0
~flangerGroup=Group.after(~phaserGroup); //flanger=1
~wahGroup=Group.after(~flangerGroup); //wahwah=2
~outputAudioStereoGroup=Group.after(~wahGroup);
~pedalOrder=[0,1,2]; //we need this to keep track of the order of the pedals



w = Window("Multieffect", Rect(100, 100, 1200, 700), false).front;//window non resizable
w.background_(Color.new(128,128,128));



w.background_(Color.grey);
w.drawFunc = {
	Pen.fillRect(Rect(0, 0, 1200, 720));
	Pen.fillColor = Color.new255(200,200,200);
	Pen.fillRect(Rect(5, 5, 1190, 690));
	Pen.fillColor = Color.black;
	Pen.fillRect(Rect(105, top-5, 190, 430));
	Pen.fillRect(Rect(505, top-5, 190, 430));
	Pen.fillRect(Rect(905, top-5, 190, 430));

};



//Basic pedals interfaces
view1 = CompositeView(w, Rect(110, top, 180, 420));
view1.background = Color.new255(245.0,124.0,47.0);
phaserLabel = StaticText(view1, Rect(45, 7, 90, 60));
phaserLabel.background = Color.new255(245.0,124.0,47.0);
phaserLabel.string_("PHASER");
phaserLabel.font = Font("Arial", 18);
phaserLabel.align_(\center);

view2= CompositeView(w, Rect(510, top, 180, 420));
view2.background_(Color.new255(235,179,38));
flangerLabel = StaticText(view2, Rect(45, 7, 90, 60));
flangerLabel.background = Color.new255(235,179,38);
flangerLabel.string_("FLANGER");
flangerLabel.font = Font("Arial", 18);
flangerLabel.align_(\center);

view3=CompositeView(w, Rect(910, top, 180, 420));
view3.background_(Color.new255(227,223,11));
wahwahLabel = StaticText(view3, Rect(45, 7, 90, 60));
wahwahLabel.background = Color.new255(227,223,11);
wahwahLabel.string_("WAH-WAH");
wahwahLabel.font = Font("Arial", 18);
wahwahLabel.align_(\center);

//NOMI KNOBS


//PHASER
freqp = StaticText(view1, Rect(85,120,70,40));
freqp.background = (Color.new255(245.0,124.0,47.0));
freqp.string_("frequency");
freqp.stringColor_(Color.black);
freqp.font = Font("Monaco", 16);
freqp.align_(\center);

depthp = StaticText(view1, Rect(40,260,70,40));
depthp.background = (Color.new255(245.0,124.0,47.0));
depthp.string_("depth");
depthp.stringColor_(Color.black);
depthp.font = Font("Monaco", 16);
depthp.align_(\center);


//FLANGER
freqf = StaticText(view2, Rect(85,120,70,40));
freqf.background = (Color.new255(235,179,38));
freqf.string_("frequency");
freqf.stringColor_(Color.black);
freqf.font = Font("Monaco", 16);
freqf.align_(\center);

ampf = StaticText(view2, Rect(25,260,70,40));
ampf.background = (Color.new255(235,179,38));
ampf.string_("amplitude");
ampf.stringColor_(Color.black);
ampf.font = Font("Monaco", 16);
ampf.align_(\center);


//WAHWAH
durwah = StaticText(view3, Rect(85,120,70,40));
durwah.background = (Color.new255(227,223,11));
durwah.string_("frequency");
durwah.stringColor_(Color.black);
durwah.font = Font("Monaco", 16);
durwah.align_(\center);

amountwah = StaticText(view3, Rect(35,260,70,40));
amountwah.background = (Color.new255(227,223,11));
amountwah.string_("amount");
amountwah.stringColor_(Color.black);
amountwah.font = Font("Monaco", 16);
amountwah.align_(\center);





//synth definition
pSynth = Synth(\myphaser,[\input_bus, firstInputChannel, \output_bus,~b1],target:~phaserGroup);


fSynth = Synth(\flanger,[\input_bus, ~b1, \output_bus,~b2,],target:~flangerGroup);


wSynth = Synth(\wahWah,[\input_bus, ~b2, \output_bus,~bout.index,],target:~wahGroup);


outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);

//////////////////////////////////////////////PHASER

//knobs
specFreqp=ControlSpec.new(0.2,1,\lin);
~knobFreqp=EZKnob.new(view1,Rect(10,110,65,70),nil,specFreqp,initVal:0.6,labelWidth:0, labelHeight:0);
~knobFreqp.action_({arg me;	pSynth.set(\mod_freq, me.value);
});

specDepthp=ControlSpec.new(0,1,\lin);
~knobDepthp=EZKnob.new(view1,Rect(105,250,65,70),nil,specDepthp,initVal:0.5,labelWidth:0, labelHeight:0);
~knobDepthp.action_({arg me; pSynth.set(\depth, me.value)});


// ON-OFF button
~buttonp= Button(view1,Rect(65,355,50,30)).states_([
	["ON",Color.red,Color(0.2,0.75,0.95)],
	["OFF",Color.black,Color.gray(0.8)]

]).font_(Font("Monaco",18)).action_({



	pSynth.free;
	if(~pedalOrder[0]==0,{

		pSynth = Synth(\myphaser,[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value],target:~phaserGroup);},{});
	if(~pedalOrder[0]==1,{
		pSynth = Synth(\myphaser,[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value],target:~phaserGroup);},{});
	if(~pedalOrder[0]==2,{
		pSynth = Synth(\myphaser,[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value],target:~phaserGroup);},{});


});



//////////////////////////////////////////////FLANGER


//knobs

specFreqf = ControlSpec.new(0, 3, \lin);
~knobFreqf = EZKnob.new(view2, Rect(10,110,65,70), nil, controlSpec:specFreqf, initVal:1.5,labelWidth:0, labelHeight:0);//FREQ
~knobFreqf.action_({arg me; fSynth.set(\freqLFO, me.value) });


specAmpf = ControlSpec.new(0, 0.005, \lin);
~knobAmpf = EZKnob.new(view2, Rect(105,250,65,70), nil, controlSpec:specAmpf, initVal:0.0025,labelWidth:0, labelHeight:0);//AMP
~knobAmpf.action_({arg me; fSynth.set(\ampLFO, me.value) });




// ON-OFF button
~buttonf= Button(view2,Rect(65,355,50,30)).states_([
	["ON",Color.red,Color(0.2,0.75,0.95)],
	["OFF",Color.black,Color.gray(0.8)]
]).font_(Font("Monaco",18)).action_({


	fSynth.free;
	if(~pedalOrder[1]==0,{
		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value],target:~flangerGroup);},{});
	if(~pedalOrder[1]==1,{
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value],target:~flangerGroup);},{});
	if(~pedalOrder[1]==2,{
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value],target:~flangerGroup);},{});

});










//////////////////////////////////////////////WAH WAH


//knobs
specDurw = ControlSpec.new(2.0,0.5, 'lin', 0.1);
~knobDurw = EZKnob.new(view3, Rect(10,110,65,70),nil,specDurw,initVal:0.5, labelWidth:0, labelHeight:0);//dur
~knobDurw.action_({arg me; wSynth.set(\dur, me.value)});


specAmountw = ControlSpec.new(0.5, 4, 'lin', 0.5);
~knobAmountw = EZKnob.new(view3, Rect(105,250,65,70),nil,specAmountw, initVal:0.5, labelWidth:0, labelHeight:0);//amount
~knobAmountw.action_({arg me; wSynth.set(\amount, me.value)});


// ON-OFF button
~buttonw= Button(view3,Rect(65,355,50,30)).states_([
	["ON",Color.red,Color(0.2,0.75,0.95)],
	["OFF",Color.black,Color.gray(0.8)]
]).font_(Font("Monaco",18)).action_({


	wSynth.free;
	if(~pedalOrder[2]==0,{
		wSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value],
			target:~wahGroup);},{});
	if(~pedalOrder[2]==1,{
		wSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value],
			target:~wahGroup);},{});
	if(~pedalOrder[2]==2,{
		wSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);},{});
});







//////////////////////////////////////////////TRANSLATION OF THE GUI









//LEFT SWITCH IMPLEMENTATION (of both GUI and audio)

leftSwitchButton = Button(w, Rect(350, 185, 100, 100));

leftSwitchButton.states = [["SWITCH!"]];

leftSwitchButton.action = { // WE USE THE ~pedalOrder ARRAY TO AKNOWLEDGE THE POSITIONS OF THE FIRST TWO PEDALS
	if((~pedalOrder[0]==0).and(~pedalOrder[1]==1),{case=0},{});//phaser and flanger
	if((~pedalOrder[0]==1).and(~pedalOrder[1]==0),{case=1},{});//flanger and phaser

	if((~pedalOrder[0]==0).and(~pedalOrder[1]==2),{case=2},{});//phaser and wah wah
	if((~pedalOrder[0]==2).and(~pedalOrder[1]==0),{case=3},{});//wah wah and phaser

	if((~pedalOrder[0]==1).and(~pedalOrder[1]==2),{case=4},{});//flanger and wah wah
	if((~pedalOrder[0]==2).and(~pedalOrder[1]==1),{case=5},{});//wah wah and flanger


	~pedalOrder.swap(0, 1); //we update the pedals order

	//phaser and flanger switch, the new configuration becomes FPW
	if (case==0,{
		view2.moveTo(110, top);
		view1.moveTo(510, top);

		//recreating the correct groups configuration
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~flangerGroup=Group.new;//1
		~phaserGroup=Group.after(~flangerGroup); //0
		~wahGroup=Group.after(~phaserGroup); //2
		~outputAudioStereoGroup=Group.after(~wahGroup);

		//recreating the correct synths, while keeping the old button and knobs values
		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value],
			target:~wahGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});

	//flanger and phaser switch, the new configuration becomes PFW
	if (case==1,{
		view1.moveTo(110, top);
		view2.moveTo(510, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~phaserGroup=Group.new;//0
		~flangerGroup=Group.after(~phaserGroup); //1
		~wahGroup=Group.after(~flangerGroup); //2
		~outputAudioStereoGroup=Group.after(~wahGroup);




		pSynth = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);

	},{});

	//phaser and wah wah switch, the new configuration becomes WPF
	if (case==2,{
		view3.moveTo(110, top);
		view1.moveTo(510, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~wahGroup=Group.new;//2
		~phaserGroup=Group.after(~wahGroup); //0
		~flangerGroup=Group.after(~phaserGroup); //1
		~outputAudioStereoGroup=Group.after(~flangerGroup);

		wSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);

	},{});
	//wah wah and phaser switch, the new configuration becomes PWF
	if (case==3,{
		view1.moveTo(110, top);
		view3.moveTo(510, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~phaserGroup=Group.new;
		~wahGroup=Group.after(~phaserGroup);
		~flangerGroup=Group.after(~wahGroup);
		~outputAudioStereoGroup=Group.after(~flangerGroup);

		pSynth = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);

	},{});

	//flanger and wah wah switch, the new configuration becomes WFP
	if (case==4,{
		view3.moveTo(110, top);
		view2.moveTo(510, top);


		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~wahGroup=Group.new;
		~flangerGroup=Group.after(~wahGroup);
		~phaserGroup=Group.after(~flangerGroup);
		~outputAudioStereoGroup=Group.after(~phaserGroup);

		wSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});

	//wah wah and flanger switch, the new configuration becomes FWP
	if (case==5,{
		view2.moveTo(110, top);
		view3.moveTo(510, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~flangerGroup=Group.new;
		~wahGroup=Group.after(~flangerhGroup);
		~phaserGroup=Group.after(~wahGroup);
		~outputAudioStereoGroup=Group.after(~phaserGroup);

		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});

};








//RIGHT SWITCH IMPLEMENTATION (of both GUI and audio)
//The logic behind this is the same as the one of previous button


rightSwitchButton = Button(w, Rect(750, 185, 100, 100));

rightSwitchButton.states = [["SWITCH!"]];



rightSwitchButton.action = {

	if((~pedalOrder[1]==0).and(~pedalOrder[2]==1),{case=0},{});//phaser and flanger
	if((~pedalOrder[1]==1).and(~pedalOrder[2]==0),{case=1},{});//flanger and phaser

	if((~pedalOrder[1]==0).and(~pedalOrder[2]==2),{case=2},{});//phaser and wah wah
	if((~pedalOrder[1]==2).and(~pedalOrder[2]==0),{case=3},{});//wah wah and phaser

	if((~pedalOrder[1]==1).and(~pedalOrder[2]==2),{case=4},{});//flanger and wah wah
	if((~pedalOrder[1]==2).and(~pedalOrder[2]==1),{case=5},{});//wah wah and flanger


	~pedalOrder.swap(1, 2);
	~pedalOrder;
	//phaser and flanger switch, the new configuration becomes WFP
	if (case==0,{
		view2.moveTo(510, top);
		view1.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~wahGroup=Group.new;//2
		~flangerGroup=Group.after(~wahGroup); //1
		~phaserGroup=Group.after(~flangerGroup); //0
		~outputAudioStereoGroup=Group.after(~phaserGroup);

		wSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});
	//flanger and phaser switch, the new configuration becomes WPF
	if (case==1,{
		view1.moveTo(510, top);
		view2.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~wahGroup=Group.new;//2
		~phaserGroup=Group.after(~wahGroup); //0
		~flangerGroup=Group.after(~phaserGroup); //1
		~outputAudioStereoGroup=Group.after(~flangerGroup);

		wSynth = Synth(\wahWah,
			[\input_bus, firstInputChannel, \output_bus,~b1,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});

	//phaser and wah wah switch, the new configuration becomes FWP
	if (case==2,{
		view3.moveTo(510, top);
		view1.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~flangerGroup=Group.new;
		~wahGroup=Group.after(~flangerhGroup);
		~phaserGroup=Group.after(~wahGroup);
		~outputAudioStereoGroup=Group.after(~phaserGroup);

		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b2, \output_bus,~bout,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});
	//wah wah and phaser switch, the new configuration becomes FPW
	if (case==3,{
		view1.moveTo(510, top);
		view3.moveTo(910, top);

		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~flangerGroup=Group.new;
		~phaserGroup=Group.after(~flangerGroup);
		~wahGroup=Group.after(~phaserGroup);
		~outputAudioStereoGroup=Group.after(~wahGroup);

		fSynth = Synth(\flanger,
			[\input_bus, firstInputChannel, \output_bus,~b1,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		pSynth = Synth(\myphaser,
			[\input_bus, ~b1, \output_bus,~b2,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value],
			target:~wahGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});

	//flanger and wah wah switch, the new configuration becomes PWF
	if (case==4,{
		view3.moveTo(510, top);
		view2.moveTo(910, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~phaserGroup=Group.new;
		~wahGroup=Group.after(~phaserGroup);
		~flangerGroup=Group.after(~wahGroup);
		~outputAudioStereoGroup=Group.after(~flangerGroup);

		pSynth = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b1, \output_bus,~b2,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b2, \output_bus,~bout,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});
	//wah wah and flanger switch, the new configuration becomes PFW
	if (case==5,{
		view2.moveTo(510, top);
		view3.moveTo(910, top);
		~phaserGroup.free;
		~flangerGroup.free;
		~wahGroup.free;
		~outputAudioStereoGroup.free;
		~phaserGroup=Group.new;
		~flangerGroup=Group.after(~phaserGroup);
		~wahGroup=Group.after(~flangerGroup);
		~outputAudioStereoGroup=Group.after(~wahGroup);


		pSynth = Synth(\myphaser,
			[\input_bus, firstInputChannel, \output_bus,~b1,\mod_freq,~knobFreqp.value,\depth,~knobDepthp.value,\bypassp,~buttonp.value]
			,target:~phaserGroup);
		fSynth = Synth(\flanger,
			[\input_bus, ~b1, \output_bus,~b2,\freqLFO,~knobFreqf.value,\ampLFO,~knobAmpf.value,\bypassf,~buttonf.value]
			,target:~flangerGroup);
		wSynth = Synth(\wahWah,
			[\input_bus, ~b2, \output_bus,~bout,\dur,~knobDurw.value,\amount,~knobAmountw.value,\bypassw,~buttonw.value]
			,target:~wahGroup);
		outputAudioStereoSynth= Synth(\outputAudioStereo,target:~outputAudioStereoGroup);
	},{});

};

//FreqScope
scopein = FreqScopeView(w, Rect(105, 470, 470, 210)).active_(true);
// activate it
scopein.background_(Color.black).waveColors_([Color.yellow]);
// set colors
scopein.dbRange_(120);  // set amplitude range (in decibels)
scopein.inBus_(firstInputChannel);

scopeout = FreqScopeView(w, Rect(635, 470, 460, 210)).active_(true);
// activate it
scopeout.background_(Color.black).waveColors_([Color.yellow]);
// set colors
scopeout.dbRange_(120);  // set amplitude range (in decibels)
scopeout.inBus_(~bout.index);



insign = StaticText(w, Rect(104,450,70,70));
//insign.background = (Color.new255(245.0,124.0,47.0));
insign.string_("INPUT");
insign.stringColor_(Color.red);
insign.font = Font("Monaco", 20);
insign.align_(\center);

outsign = StaticText(w, Rect(640,450,75,70));
//insign.background = (Color.new255(245.0,124.0,47.0));
outsign.string_("OUTPUT");
outsign.stringColor_(Color.red);
outsign.font = Font("Monaco", 20);
outsign.align_(\center);



w.front;
w.onClose_({CmdPeriod.run});
)