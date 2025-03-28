function [pows, freq] = analisar_espectro_potencia(X, Fs)
  N = length(X);
  amp = fftshift(fft(X));
  fN = N - mod(N, 2);
  k = -fN/2 : fN/2 - 1;
  T = N / Fs;
  freq = k/T;
  one_idx = fN/2 + 2;
  amp = amp(one_idx:end);
  freq = freq(one_idx:end);
  if(size(freq, 2) < size(amp, 2))
    amp = amp(1:end-1);
  end
  pows = abs(amp).^2;
end
