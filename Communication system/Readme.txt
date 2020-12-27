			README
Contains full design of BPSK using MORSE encoder at transmittion 
   and Demodulation and Decoding at Reciever except the WGN in the medium.

step1)converting input signal to morse code.
step2)Mapping the morse code to corresponding Binary numbers using some logic
	%  A '.' is represented by 1.
	%  A '-' is represented by 111.
	% An inter-element space is represented by 0 separation (put between two dots or two hashes).
	% An inter-letter(per character space ' ' in MORSE) is represented by 000 .
	% An inter-word space '       ' in MORSE is represented by 0000000.
step3) converting binary to NRZ (no Return Zero) type by mapping 1=>1 and 0=>-1.
step4)modulating it with carrier wave of frequency 5 .(assumed no noise is added )
step5)demodulating to get impulse waveform.
step6)converting impulse waveform to Binary .
step7)converting binary back to normal charracters and matching it with the signal given for errors.
