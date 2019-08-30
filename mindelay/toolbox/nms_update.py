from mmdet.ops.nms.nms_wrapper import nms
import numpy as np
def nms_update(result, thres):
    n = result.__len__()
    for i in range(n):
        result[i] = nms(result[i], thres)

    return result