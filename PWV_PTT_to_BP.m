function [SBP, DBP] = PWV_PTT_to_BP(PTT, PWV)
	tx = textscan(fopen('BP_equations.txt'),'%s','delimiter','\n'); 

    eq = tx{1};
    eqSBP = eq{1};
    eqDBP = eq{2};

    % SBP
    if strfind(eqSBP, "PTT")
        str = strcat(['@(', 'PTT', ')', eqSBP]);
        temp = PTT;
    else
        str = strcat(['@(', 'PWV', ')', eqSBP]);
        temp = PWV;
    end

    fun = str2func(str);
    SBP = fun(temp);

    % SBP
    if strfind(eqDBP, "PTT")
        str = strcat(['@(', 'PTT', ')', eqDBP]);
        temp = PTT;
    else
        str = strcat(['@(', 'PWV', ')', eqDBP]);
        temp = PWV;
    end

    fun = str2func(str);
    DBP = fun(temp);

end
