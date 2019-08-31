import numpy as np
import mindelay.toolbox.IoU as IoU


def update_traj(old, det):
    prior = 0.5
    for i in range(old.shape[0]):
        a = old[i, 0:4] * prior
        b = prior
        l = prior * 0.5
        for j in range(det.shape[0]):
            weight = (IoU(old[i, 0:4], det[j, 0:4])>0.5)*IoU(old[i, 0:4], det[j, 0:4])
        # The bounding box update is here. I've tried different methods in the original Matlab code. 
        # But here I just use the previous frame as the guidance of current frame and leave it as-is.
        # I will combine it with trackers (some work to be done!) and update in later version of the code. 
            a = a + weight * det[j, 0:4]
            b = b + weight
            l = l + weight * det[j, 4]
        old[i, 0:4] = a / b
        l = l / b

        temp_lr = np.log(l + 0.25) - np.log((1 - l) + 0.25) + old[i, 4] - 2.5/b
        # the +0.25 is making the output smoother. If the output of the detector is not ideal you may want to tune it.
        # the 2.5/b is a prior. Instead of setting a fixed prior I am trying to make it adaptive. Feel free to play with it! 
        
        old[i, 4] = max(temp_lr, 0)

    return old


def update(result, result_det):
    n = result.__len__()
    for i in range(n):
        result[i] = update_traj(np.array(result[i]), np.array(result_det[i]))

    return result
