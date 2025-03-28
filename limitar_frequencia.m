function [pass_pows pass_freq] = limitar_frequencia(potencias, frequencias, lim_inferior, lim_superior)
  range = min(find(frequencias > lim_inferior)):max(find(frequencias < lim_superior));
  pass_pows = potencias(range);
  pass_freq = frequencias(range);
end
