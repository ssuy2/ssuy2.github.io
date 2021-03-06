%Program 11.1 Audio codec
%input: vector x of input signal
%output: vector out of output signal
%Example usage: out=simplecodec(cos((1:2^(12))*2*pi*256/2^(13)));
%               example signal is 1/2 sec. pure tone of frequency f = 256
function out=simplecodecwindow(x)
len=length(x);
n=2^5;                                % length of window
nw=floor(len/n);                      % number of length n windows in x
x=x(1:n*nw);                          % cut x to integer number of n windows
%Fs=2^(13);
Fs=44100;                            % Fs=sampling rate
b=8; L=0.3;                           % b = quantization bits, [-L,L] amplitude range
q=2*L/(2^b-1);                        % q used for b bits on interval [-L, L]
for i=1:n                             % form the MDCT matrix
  for j=1:2*n
    M(i,j)= cos((i-1+1/2)*(j-1+1/2+n/2)*pi/n);
  end
end
M=sqrt(2/n)*M;
N=M';                                 % inverse MDCT
%x=cos((1:T*Fs)*2*pi*64*f/Fs);         % test signal
%x=x+cos((1:4096)*2*pi*64*5/Fs); 
%x=x+cos((1:4096)*2*pi*64*6/Fs);
x=0.3*x/max(abs(x));                  % normalize signal to max amplitude = 0.3
sound(x,Fs)                           % Matlab's sound command
out=[];
for k=1:nw-1                          % loop over l ength 2n windows
  x0=x(1+(k-1)*n:2*n+(k-1)*n)';
  j = 1:2*n;
  h = sqrt(2)*sin((j-0.5)*pi/(2*n))';
  y0=M*(x0.*h);
  y1=round(y0/q);                     % transform components quantized
% Storage/transmission of file occurs here  
  y2=y1*q;                            % transform components dequantized
  w(:,k)=(N*y2).*h;                        % invert the MDCT
  if(k>1)
      w2=w(n+1:2*n,k-1);w3=w(1:n,k);
      out=[out;(w2+w3)/2];          % collect the reconstructed signal
  end                                 % (of length 2n less than length of x)
end
pause(1)
sound(out,Fs)                         % play the reconstructed tone
audiowrite('Better8bitwindow.wav', out, Fs);
xshort = x(n+1:end-n);
plot(xshort(1:100))
hold on 
rmse_result = norm(xshort'-out)/sqrt(length(xshort))
plot(out(1:100))



