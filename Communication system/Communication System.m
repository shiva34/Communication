clear;
% we take the input signal as string and convert it to international morse code 
text1=string(input ('(Please Enter text(signal) to encode : \n','s'));
%NOTE: the code does not allow any space before and after the message , any
%such space will be removed automatically to match the syntax of encoder.
%As we are matching each letter and converting to corresponding Morse code
%we convert everything to UPPERCASE to ensure everything is similar and
%matching part gets easier.
text1=string(upper(text1));
input=text1;
%matching every character gets easier in character string so we convert it
%to character string where we can get individual characters by adress.
text1 =convertStringsToChars(text1);
%Next we take two arrays to match each characted to corresponding Morse
%code character . We also define space as 7 blank space in MORSE as per the
%standard International Morse code.
%the usable characters are
%a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ,0,1,2,3,4,5,6,7,8,9
morse={'. -','- . . .','- . - .','- . .','.','. . - .','- - .','. . . .','. .','. - - -','- . -','. - . .','- -','- .','- - -','. - - .','- - . -','. - .','. . .','-','. . -','. . . -','. - -','- . . -','- . - -','- - . .','. - - - -','. . - - -','. . . - -','. . . . -','. . . . .','- . . . .','- - . . .','- - - . .','- - - - .','- - - - -','       '};
letter={'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','1','2','3','4','5','6','7','8','9','0',' '};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MORSE Encoder
encoded="";  %to store morse encoded string
fprintf('%s',"Morse encoded string is : {");  % To print the morse encoded string
for i=1:length(text1)
    for j=1:length(morse)
      if strcmpi(text1(i),letter(j))==1
        fprintf('%s',string(morse(j))); %just to print encoded string can also be done using the encoded 
        encoded=encoded+morse(j)+"   "; %keeps adding individual morse characters in char array encoded.
        fprintf('%s',"   ");
      end
    end
end
fprintf('%s\n',"}");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Converting MORSE code to binary to use BPSK
%  A '.' is represented by 1.
%  A '-' is represented by 111.
% An inter-element space is represented by 0 separation (put between two
%       dots or two hashes).
% An inter-letter(per character space ' ' in MORSE) is represented by 000 .
% An inter-word space '       ' in MORSE is represented by 0000000.
conv =convertStringsToChars(encoded); %To convert it to binary
binary= "";
for i=1:length(conv)
    if strcmp(conv(i),'.')==1
        binary =binary+ "1";
    end   
    if strcmp(conv(i),'-')==1
        binary=binary+"111";
    end
    if strcmp(conv(i),' ')==1
        binary=binary + "0";
    end 
end
fprintf("\nMORSE code converted to binary is :   %s \n",binary);     %%To show the Binary converted string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BPSK Modulation Part
%The Orthonormal basis for BPSK is sqrt(2/T)Cos(2*Pi*f*t)  
%where T is Bit rate (Bits/sec), f is frequency of Carrier signal(sinosoid)
T=1; % We take bit rate as 1 Bit/sec 
%The two waveforms corresponding to 1 and 0 are in Phase and inverted with
%respect to each other .
%as BPSK signal is bit(t)*A*Cos(2*Pi*f*t) we use NRZ representation (No
%Return Zero type) here we map binary signal to Bipolar waveform . 1=>1 ans 0=>-1
bin=convertStringsToChars(binary); % To convert it to char string
modulate=[]; % NRZ representation of out binary signal
for i=1:length(bin)
    if strcmp(bin(i),"1")==1
        modulate=[modulate ones(1,200)*1];  % considering pulse will be of amplitude 1
    elseif strcmp(bin(i),"0")==1
        modulate=[modulate ones(1,200)*(-1)];
    end    
end 
figure(1);
plot(modulate);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('Generated impulse waveform');
%as we have 200 values per secong or a value every 1/200=0.005 sec
t=0.005:0.005:length(bin); % To take values every .005 sec
%Frequency of the carrier
f=5;
%Here we generate the modulated signal by multiplying carrier sinosoid
%signal with the modulate impulse waveform
modulated=modulate.*(sqrt(2/T)*cos(2*pi*f*t)); % To get the value of modulated array
figure(2);
plot(modulated);
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)-->');
title('BPSK Modulated signal');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%transferred to medium
snr=1;   % have to take more values to plot later
%recieved=awgn(modulated,snr,'measured');%we have to add noise but realised missing toolboxes at the right moment.
recieved=modulated; %Will try to making change in earlier one if got time after adding toolboxes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BPSK DEModulation part
y=[];
%We begin demodulation by multiplying the received signal again with 
%the modulate impulse waveform
demodulated=recieved.*(sqrt(2/T)*cos(2*pi*f*t));
%Here we perform the integration over time period T using trapz 
%Integrator is an important part of correlator receiver used here
figure(3);
plot(demodulated);
title('Impulses of Received bits after multiplying again with carrier wave');
xlabel('Time (seconds)-->');
ylabel('Amplitude (volts)')
for i=1:200:size(demodulated,2)
 y=[y trapz(t(i:i+199),demodulated(i:i+199))];
end
rimpulse=y>0; % we don't take negative values and round them to binary negative
              %gets rounded to 0 and positive number gets rounded to 1.
%rimpulse is a logical array 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%To convert recieved baseband binary signal back to MORSE code.
rbinarytemp= rimpulse; %To store logical array
demodulated=""; % To convert Binary to MORSE
count=0;        %To deal with 111 corresponding to '-'
for i=1:length(rbinarytemp)
    if rbinarytemp(i)==1
        if i+1<length(rbinarytemp)
            if rbinarytemp(i+1)==1               
                count=count+1;
                if count ==2   %takes care of the case when we have 111 in binary
                   demodulated =demodulated+ "-"; 
                end
            elseif count==2
                count=0;
            else demodulated = demodulated+ ".";
            end
        else demodulated = demodulated+ ".";   
        end 
    else demodulated = demodulated+" ";
    end    
end
fprintf("\nrecieved signal demodulated to MORSE Code {%s}\n",demodulated);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Morse Decoder
%Since we had defined 7 spaces as a MORSE character for a blank space we
%need to split the string such that it does not affect comparing of other 
%MORSE characters and converting them back to normal english alphabets.
Baseband=demodulated;
%NOTE: if we put space more than once it will be detected only once which
%is acceptable . so we split and later remove all proceeding and trailing
%space characters to remove error due to space characters while decoding
%from morse code . As we are matching each character space can lead to
%major errors so need to be managed properly.
splitBase=strsplit(Baseband,"     ");
%We remove all additional spaces to only get 1 space.
splitBase=strip(splitBase);
decoded="";
%length(splitBase); To get length to get a idea 

for k=1:length(splitBase)
    temp=strsplit(splitBase(k),"   ");
    for i=1:length(temp)    %To do the conversion properly by removing 3 spaces between individual letters of a word
        for j=1:length(morse)
            if strcmpi(temp(i),morse(j))==1
                %fprintf('%s',string(letter(j)));
                decoded=decoded+letter(j); %keeps adding individual decoded characters in string decoded.
            end
        end
    end
    decoded=decoded+' ';
end
%We are stripping the signal again to ensure that leading and trailing
%spaces are removed as we assume that nobody sends space in between and if
%some space occurs due to some error before or after the message it shall
%be removed .
decoded=strip(decoded);
fprintf("decoded string is {%s}",decoded);
if strcmp(decoded,input)==1
    fprintf("\nNo error occured & Output matches input ");
end
%NOTE : COuld not add noise in given time  so did not do any SNR plot and
%Time axis for plots is not properly scaled .