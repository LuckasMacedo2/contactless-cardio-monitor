function [z_stat] = detrending(z, lambda)
    T = length(z);
    I = speye(T);
    D2 = spdiags(ones(T-2,1)*[1 -2 1],[0:2],T-2,T);
    z_stat = full(I-inv(I+lambda^2*D2'*D2));
    z_stat = z_stat*z;
end