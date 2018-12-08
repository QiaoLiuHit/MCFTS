
function initial_net(pathModel)
global net;
net = load(pathModel);
net.layers(37+1:end)=[];
net=vl_simplenn_move(net,'gpu');
end
