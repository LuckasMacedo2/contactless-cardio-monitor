% Retirado de Souza (2019)
function y_inter = interpolation(y, fs, fs_inter)
    z = 0:size(y, 2) - 1;
    zz = linspace(0,size(y, 2) - 1, (size(y, 2)/fs)*fs_inter);
    y_inter = spline(z, y, zz);
end