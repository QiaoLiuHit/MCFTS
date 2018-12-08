function c = find_nh_scale(regrets,A)

%%first find an upper and lower bound on c, based on the nh weights
clower = 1.0; counter=0;
while (avgnh(regrets, clower, A) < 0) && counter<30
  clower = clower * 0.5;
  counter=counter+1;
end

cupper = 1.0;counter=0;
while (avgnh(regrets, cupper, A) > 0) && counter<30
  cupper = cupper * 2;
  counter=counter+1;
end

%now do a binary search

cmid = (cupper + clower)/2;counter=0;
while(abs(avgnh(regrets, cmid, A)) > 1e-2) && counter<30
  if (avgnh(regrets, cmid, A) > 1e-2)
    clower = cmid;
    cmid = (cmid + cupper)/2;
  else
    cupper = cmid;
    cmid = (cmid + clower)/2;
  end
  counter = counter+1;
end

c = cmid;

