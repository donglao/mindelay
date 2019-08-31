function  [num_det, num_fa, delay_avg,  total_delay_detected,IoU_sum_detected] = evaluate_result(result, tracklets, changetime, threshold, IoU_lim, num_obj, distime)
get = zeros(num_obj, 2);
IoU_get = zeros(num_obj,1);
for i = 1:length(result)% i: time; j: object
    % associate result with the previous frame
    % evaluate only when detected is zero
    [n,m] = size(result{i});
    if i > 1
        [nn,~] = size(result{i-1});
        for j = 1:n
            detected{i}(j) = 0;
            for k = 1:nn
                if IoU(result{i}(j,1:4),result{i-1}(k,1:4))>=IoU_lim
                    detected{i}(j) = detected{i-1}(k);
                end
            end
        end
    else
        for j = 1:n
            detected{i}(j) = 0;
        end
    end
    %
    
    for j = 1:n
        valid{i}(j) = 0; % initialize
        bad{i}(j) = 0;
        check = (max(result{i}(j,6:m))>threshold);
        if check == 1
            temp = detected{i}(j); % temp indicates whether the object was already detected in the previous frame
            detected{i}(j) = 1;
            bad{i}(j) = 1;
            for k = 1:length(tracklets{i})
                if tracklets{i}(k).id>0
                    overlapping = IoU(result{i}(j,1:4),[tracklets{i}(k).x1,tracklets{i}(k).y1,tracklets{i}(k).x2,tracklets{i}(k).y2]);
                    if get(tracklets{i}(k).id,1) == 0 % Only one correct detection can be counted for one object!
                        valid{i}(j) = valid{i}(j)+(overlapping>=IoU_lim);
                    end
                    bad{i}(j) = bad{i}(j) - (overlapping>=IoU_lim);
                    if overlapping >= IoU_lim && temp == 0
                        get(tracklets{i}(k).id,1) = 1;
                        if get(tracklets{i}(k).id,2)==0
                            get(tracklets{i}(k).id,2) = i;
                            IoU_get(tracklets{i}(k).id) = overlapping;
                        end
                    end
                    valid{i}(j) = logical(valid{i}(j));
                    bad{i}(j) = (bad{i}(j)>0);
                    if temp == 1
                        bad{i}(j) = 0; % if already detected in the previous frame, only count false alarm once
                    end
                end
            end
        end
    end
    if isempty(result{i}) % in case that no detection at this frame
        valid{i} = 0;
        bad{i} = 0;
    end
    detection(i) = sum(valid{i});
    false_alarm(i) = sum(bad{i});
end
num_det = sum(get(:,1));
num_fa = sum(false_alarm);
det_time = get(:,2);

%         det_time(det_time==0)= length(result); % replace the distime
obj_detected = logical(det_time);

for i = 1:length(det_time)
    if det_time(i) == 0
        det_time(i) = distime(i);
    end
end
delay_avg = sum(det_time'-changetime)/double(num_obj);
total_delay_detected = sum((det_time'-changetime).*obj_detected');
IoU_sum_detected = sum(IoU_get);

end
