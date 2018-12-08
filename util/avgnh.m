function total = avgnh(r, c, A)
	n = numel(r);
    T = r+A;
    T(T<0)=0;
    w = exp(0.5*T.*T/c);
    total = (1/n)*sum(w)-2.72;

