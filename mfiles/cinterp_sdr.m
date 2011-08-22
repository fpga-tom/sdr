clear;
R=40;
D=1;
Nsecs=5;
IWL=8;
IFL=7;
OWL=14;
Fc=256e3;
Fs=Fc*R;
hcic=mfilt.cicinterp(R,D,Nsecs, IWL,OWL);
hcic.InputFracLength=IFL;
%fvtool(hcic, 'Fs', 10e6);
hgain=dfilt.scalar(1/gain(hcic));
hcicnorm=cascade(hgain,hcic);
%fvtool(hcicnorm, 'Fs',10e6);
%% Cic compensation filter
L=10;
Fo=.5;
p=2e3;
s=.25/p;
fp=[0:s:Fo];
fs=[(Fo+s):s:.5];
f=[fp fs]*2;
Mp=ones(1,length(fp));
Mp(2:end)=abs(D*R*sin(pi*fp(2:end)/R)./sin(pi*D*fp(2:end))).^Nsecs;
Mf=[Mp zeros(1,length(fs))];
f(end)=1;
h=fir2(L,f,Mf);
h=h/max(h);
ch=dfilt.dffir(h);
set(ch,...
    'Arithmetic',      'fixed',...
    'CoeffWordLength',  8,...
    'InputWordLength',  8,...
    'InputFracLength', -7);
hcas=cascade(ch,hcic);
fvtool(hcas, 'Fs', Fs);
workingdir=tempname
generatehdl(hcas, 'Name', 'cic_filter', 'TargetLanguage', 'VHDL', ...
    'TargetDirectory', fullfile(workingdir, 'hdlsrc'));
