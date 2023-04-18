(
SystemClock.sched(2.0,{
    "2.0 seconds later".postln;
    2;
});
)

(
s.boot;
s.latency = 0.01;
)


(
~pedalOrder=[0,1,2]; //phaser=0 , flager=1 , wah wah=2
~bin = Bus.audio(s);
~b1 = Bus.audio(s);
~b2= Bus.audio(s);
~bout= Bus.audio(s);
// Out.ar(~bin,SoundIn.ar(0));
)

//TRE EFFETTI DI SEGUITO

(
SynthDef(\myphaser, {
	arg depth=0.5, mod_freq=0.6;
	var input, output, phased_input;
	var output_bus, last=false;//dichiarare false qui potrebbe darmi problemi nel collegamento pedali 2 e 3
	//probabilmente bisogna mettere una qualche variabile "isFirst"
	var num=4;

	if(~pedalOrder.indexOf(0)==0,{
		Out.ar(~bin,SoundIn.ar(0));input =In.ar(~bin.index);output_bus=((~b1.index));},{});
	if(~pedalOrder.indexOf(0)==1,{input =In.ar(~b1.index);output_bus=((~b2.index));},{});
	if(~pedalOrder.indexOf(0)==2,{input =In.ar(~b2.index);output_bus=((~bout.index));last=true;},{});


	phased_input=input;
	while({num>0},{
		phased_input = AllpassC.ar(phased_input, 2, SinOsc.kr(mod_freq, 0, 0.0015,0.005), 0, 1);num=num-1});

	output = Mix.ar([input,phased_input*depth]);
	Out.ar(output_bus, output);
	if(last,{Out.ar([0,1], In.ar(output_bus));},{});
}).add;


SynthDef("flanger", {

	arg ampLFO = 0.0025, freqLFO = 1.5;
	var gff=1;
	var gfb=0.1;

	var maxdelay=0.01;

	var signal_x,signal_x_delayed, output;
	var myLFO, maxdepth, basedelay;
	var output_bus, last=false;

	//////////////

	if(~pedalOrder.indexOf(1)==0,{
		Out.ar(~bin,SoundIn.ar(0));signal_x =In.ar(~bin.index);output_bus=((~b1.index));},{});
	if(~pedalOrder.indexOf(1)==1,{signal_x =In.ar(~b1.index);output_bus=((~b2.index));},{});
	if(~pedalOrder.indexOf(1)==2,{signal_x =In.ar(~b2.index);output_bus=((~bout.index));last=true;},{});




	basedelay=maxdelay/2;
	//  maxdepth=basedelay/2;

	myLFO = SinOsc.kr(freqLFO,mul:ampLFO);

	//PROCESS

	signal_x_delayed = DelayC.ar(signal_x, maxdelay,basedelay+ myLFO);
	signal_x = Mix.ar([signal_x, signal_x_delayed*(gfb)]);
	output = Mix.ar([signal_x_delayed*gff,signal_x]);
	Out.ar(output_bus,output);
	if(last,{Out.ar([0,1], In.ar(output_bus));},{});
	//Out.ar([0,1], In.ar(output_bus));
}).add;




​





SynthDef(\wahWah,{
	arg dur = 0.5, fw = 350;
	var bpf, e, lpf, output, mix, input, output_bus, last=true; //fw => wah frequency

	//SystemClock.sched(1.0,{
	if(~pedalOrder.indexOf(2)==0,{
		Out.ar(~bin,SoundIn.ar(0));input =In.ar(~bin.index);output_bus=((~b1.index));},{});
	if(~pedalOrder.indexOf(2)==1,{input =In.ar(~b1.index);output_bus=((~b2.index));},{});
	if(~pedalOrder.indexOf(2)==2,{input =In.ar(~b2.index);output_bus=((~bout.index));last=true;},{});
	//if(~pedalOrder.indexOf(2)==1,{//Out.ar(~bin,SoundIn.ar(0));
		//input =In.ar(~b1.index);output_bus=((~b2.index));last=true;},{});  //TEST FUNCTIONS

	e = Env([1,6.28,1], [dur/2,dur/2]);
	//input=In.ar(busIn,1);
	bpf = BPF.ar(input, fw*EnvGen.kr(e,SinOsc.kr(1/dur))); //Capire se far variare anche la larghezza della banda
	mix = Mix.ar([input,2*bpf]);
	output = LPF.ar(mix,10000);
	Out.ar(output_bus,output);
	if(last,{Out.ar([0,1],In.ar(output_bus));},{});
	//Out.ar([0,1],In.ar(output_bus));



		//});
}).add;
)

(
~phaserGroup=Group.new;//0
~flangerGroup=Group.after(~phaserGroup); //1
~wahGroup=Group.after(~flangerGroup); //2

~phaser=Synth(\myphaser,target:~phaserGroup);
~flanger=Synth(\flanger,target:~flangerGroup);
~wah=Synth(\wahWah,target:~wahGroup);
)
(
~phaserGroup=Group.new; //0
~wahGroup=Group.after(~phaserGroup); //2
~flangerGroup=Group.after(~wahGroup); //1

~phaser=Synth(\myphaser,target:~phaserGroup);
~flanger=Synth(\flanger,target:~flangerGroup);
~wah=Synth(\wahWah,target:~wahGroup);
)







//WAH DI PROVA BRUTTO
/*
(
SynthDef(\wahWah,{
	arg dur = 0.5, fw = 350;
	var bpf, e, lpf, output, mix, input, output_bus, last=true; //fw => wah frequency

	SystemClock.sched(1.0,{

		if(~pedalOrder.indexOf(2)==0,{
			Out.ar(~bin,SoundIn.ar(0));input =In.ar(~bin.index);output_bus=((~b1.index));},{});
		if(~pedalOrder.indexOf(2)==1,{input =In.ar(~b1.index);output_bus=((~b2.index));},{});
		if(~pedalOrder.indexOf(2)==2,{Out.ar(~bin,SoundIn.ar(0));
			input =In.ar(~bin.index);output_bus=((~bout.index));last=true;},{});
	});

	//SystemClock.sched(1.0,{


	//if(~pedalOrder.indexOf(2)==1,{//Out.ar(~bin,SoundIn.ar(0));
		//input =In.ar(~b1.index);output_bus=((~b2.index));last=true;},{});  //TEST FUNCTIONS

	e = Env([1,6.28,1], [dur/2,dur/2]);
	//input=In.ar(busIn,1);
	bpf = BPF.ar(input, fw*EnvGen.kr(e,SinOsc.kr(1/dur))); //Capire se far variare anche la larghezza della banda
	mix = Mix.ar([input,2*bpf]);
	output = LPF.ar(mix,10000);
	Out.ar(output_bus,output);
	if(last,{Out.ar([0,1],In.ar(output_bus));},{});
	//Out.ar([0,1],In.ar(output_bus));



		//});
}).add;
)

x=Synth(\wahWah);
*/



(var wahSynth;
    ~wahRoutine= Routine({
	if(true,{1.wait;},{});
	wahSynth = Synth(\wahWah);

});
)

~wahRoutine.play;
// ~wahRoutine.stop;
~wahRoutine.reset;
































