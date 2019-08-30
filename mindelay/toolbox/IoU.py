import numpy as np


def IoU(box1, box2):
    I = max(min(box1[2], box2[2]) - max(box1[0], box2[0]), 0) * max(min(box1[3], box2[3]) - max(box1[1], box2[1]), 0)
    U = (box1[2] - box1[0]) * (box1[3] - box1[1]) + (box2[2] - box2[0]) * (box2[3] - box2[1]) - I
    return I / U
