%run the given videos
function runAll_vottir
seqTir={
    'birds'
};
    for s=1:numel(seqTir)
        run_tracker(seqTir{s});
    end
end
