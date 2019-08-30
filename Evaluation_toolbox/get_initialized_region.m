function [output_boxes, ind] = get_initialized_region(raw, threshold, ind)
[n,m] = size(raw);
if nargin < 3 || isempty(ind)
    ind = [[1:n]',zeros(n,1)];
else
    [temp_n, ~] = size(ind);
    ind = [ind; [max(ind(:,1))+1:max(ind(:,1))+n-temp_n]',zeros(n-temp_n,1)];
end
m = m-5;
% run nms
[~, cat_max] = max(raw(:,6:5+m),[],2);
selection = ind(:,2);
for i = 1:m-1
    selection_temp = false(n,1);
    selection_temp(nms([raw(:, 1:4), raw(:, i+5)],threshold)) = 1;
    selection_temp = selection_temp.*(cat_max == i);
    selection = selection + selection_temp;
end
selection = logical(selection);
temp_boxes = raw(selection, :);
ind = ind(selection,:);
selection = (max(temp_boxes(:,6:m+5),[],2)>0.2);
% boxes = temp_boxes(selection(:), :);
% remove the boxes labeled as the background
[~, cat] = max(temp_boxes(:,6:m+5),[],2);
selection(cat==m) = 0;
% remove impossible rectangles
bad = logical((temp_boxes(:,3)<=temp_boxes(:,1))+(temp_boxes(:,4)<=temp_boxes(:,2)));
selection(bad) = 0;

    output_boxes = temp_boxes(selection(:),:);
    ind = ind(selection(:),:);
end