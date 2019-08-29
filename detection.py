import mmcv
from mmcv.runner import load_checkpoint
from mmdet.models import build_detector
from mmdet.apis import inference_detector, show_result
import numpy as np
import os
import mindelay.toolbox as toolbox
import mindelay.association as association
import copy
import time
import scipy.io

cfg_file = 'your_dir/configs/faster_rcnn_r101_fpn_1x.py'
checkpoint_file = 'your_dir/faster_rcnn_r101_fpn_1x_20181129-d1468807.pth'
data_dir = 'KITTI_dir/data_tracking_image_2/training/image_02/'
result_dir = 'your_dir/result/'
os.makedirs(result_dir, exist_ok=True)

cfg = mmcv.Config.fromfile(cfg_file)
cfg.model.pretrained = None

model = build_detector(cfg.model, test_cfg=cfg.test_cfg)
load_checkpoint(model, checkpoint_file)

num_frames = [154, 447, 233, 144, 314, 297, 270, 800, 390, 803, 294, 373, 78, 340, 106, 376, 209, 145, 339, 1059, 837]
num_cat = 80

for dataset in range(21):
    output = [[]]*num_frames[dataset]
    output_raw = [[]] * num_frames[dataset]
    result = toolbox.initialize_result(num_cat)
    for i in range(num_frames[dataset]):
        print(i)
        img = mmcv.imread(data_dir + '%.4i' % dataset + '/' + '%.6i' % i + '.png')
        result_det = inference_detector(model, img, cfg)
        t = time.time()
        result = association.update(result, result_det)
        # result = likelihoo024d.update(result, result_det)
        result = toolbox.combine_result(result, result_det, 0.5)
        # print(time.time()-t)
        output[i] = copy.deepcopy(result)
        output_raw[i] = copy.deepcopy(result_det)

    scipy.io.savemat(result_dir + '%.4i' % dataset + '.mat', {"result": output})
    scipy.io.savemat(result_dir + '%.4i' % dataset + '_raw.mat', {"result": output_raw})