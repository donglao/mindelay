import numpy as np


def initialize_result(num_cat):
    return [np.zeros([0, 5])] * num_cat


def process_result(result):
    n = result.__len__()
    k = 0
    for i in range(n):
        k = k + result[i].shape[0]

    output_box = np.ones([k, 5])
    output_likelihood = np.zeros([k, n])
    k = 0
    for i in range(n):
        output_box[k:k + result[i].shape[0], 0:4] = result[i][:, 0:4]
        output_likelihood[k:k + result[i].shape[0], i] = result[i][:, 4]
        k = k + result[i].shape[0]
    return output_box, output_likelihood
