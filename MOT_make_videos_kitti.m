% --------------------------------------------------------
% MDP Tracking
% Copyright (c) 2015 CVGL Stanford
% Licensed under The MIT License [see LICENSE for details]
% Written by Yu Xiang
% --------------------------------------------------------
function MOT_make_videos_kitti

is_save = 1;

opt = globals();
N = numel(opt.kitti_test_seqs);
seq_set = 'testing';

for seq_idx = 1:N
    close all;
    hf = figure(1);
    
    seq_name = opt.kitti_test_seqs{seq_idx};
    seq_num = opt.kitti_test_nums(seq_idx);
    
    % build the dres structure for images
    filename = sprintf('%s/kitti_%s_%s_dres_image.mat', opt.results_kitti, seq_set, seq_name);
    if exist(filename, 'file') ~= 0
        object = load(filename);
        dres_image = object.dres_image;
        fprintf('load images from file %s done\n', filename);
    else
        dres_image = read_dres_image_kitti(opt, seq_set, seq_name, seq_num);
        fprintf('read images done\n');
        save(filename, 'dres_image', '-v7.3');
    end
    
    % read tracking results
    filename = sprintf('results_kitti/test_subcnn_1/%s.txt', seq_name);
    dres_track = read_kitti2dres(filename);
    fprintf('read tracking results from %s\n', filename);
    ids = unique(dres_track.id);
    cmap = colormap(hsv(numel(ids)));
    cmap = cmap(randperm(numel(ids)),:);
    
    if is_save
        file_video = sprintf('results_kitti/test_subcnn_1/%s.avi', seq_name);
        aviobj = VideoWriter(file_video);
        aviobj.FrameRate = 9;
        open(aviobj);
        fprintf('save video to %s\n', file_video);
    end
    
    for fr = 1:seq_num
        show_dres(fr, dres_image.I{fr}, '', dres_track, 2, cmap);
        if is_save
            writeVideo(aviobj, getframe(hf));
        else
            pause;
        end
    end
    
    if is_save
        close(aviobj);
    end
end