clear all;  clc;
addpath('./Evaluation_toolbox');

%% for min-delay result
[total_fa,total_det,total_delay,total_delay_detected,total_detected_IoU] = deal(zeros(1,99));
total_obj =0;
IoU_lim = 0.5;

for seq_idx = 0:20
    disp(seq_idx);
    dataset = num2str(seq_idx,'%04i');
    [tracklets, num_obj, changetime,distime] = load_ground_truth(seq_idx);
    total_obj = total_obj + num_obj;
    result = convert_result(dataset);
%     for step = 1:99
    parfor step = 1:99 % for faster evaluation, use parallel
%         disp(step)
        threshold = 1.5+step*0.2; % vary the threshold to generate scatter plot
% Note that each step takes care of one point in the scatter plot. 
% The scatter plot will only be reasonable if you have chosen the right range of the threshold.

        [num_det(step), num_fa(step), delay_avg(step), delay_detected(step), IoU_sum(step)] = ...
            evaluate_result(result, tracklets, changetime, threshold, IoU_lim, num_obj,distime);
        delay_sum(step) = delay_avg(step)*double(num_obj);
    end
    total_det = total_det + num_det;
    total_fa = total_fa + num_fa;
    total_delay = total_delay + delay_sum;
    total_delay_detected = total_delay_detected + delay_detected;
    
    total_detected_IoU = total_detected_IoU + IoU_sum;
end
figure;
scatter(total_fa./(total_det+total_fa),total_delay/double(total_obj),50,'filled'); hold on;
xlabel('False Alarm Rate');
ylabel('Average Detection Delay');

%% for raw result
[total_fa,total_det,total_delay,total_delay_detected,total_detected_IoU] = deal(zeros(1,99));
total_obj =0;
IoU_lim = 0.5;

for seq_idx = 0:20
    disp(seq_idx);
    dataset = num2str(seq_idx,'%04i');
    [tracklets, num_obj, changetime,distime] = load_ground_truth(seq_idx);
    total_obj = total_obj + num_obj;
    result = convert_result(dataset,'raw');
    for i = 1:length(result)
        [result{i}, ~] = get_initialized_region(result{i}, IoU_lim);
    end
%     for step = 1:99
    parfor step = 1:99 % for faster evaluation, use parallel
%         disp(step)
        threshold = 1.5 + step*0.0015;
        [num_det(step), num_fa(step), delay_avg(step), delay_detected(step), IoU_sum(step)] = ...
            evaluate_result(result, tracklets, changetime, threshold, IoU_lim, num_obj,distime);
        delay_sum(step) = delay_avg(step)*double(num_obj);
    end
    total_det = total_det + num_det;
    total_fa = total_fa + num_fa;
    total_delay = total_delay + delay_sum;
    total_delay_detected = total_delay_detected + delay_detected;
    
    total_detected_IoU = total_detected_IoU + IoU_sum;
end
scatter(total_fa./(total_det+total_fa),total_delay/double(total_obj),50,'filled');
xlim([0.1, 0.6]);
grid on;
legend('Min-delay', 'Single image');
