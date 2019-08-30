function result = convert_result(dataset, raw)
% mkdir processed;
if nargin == 1
    load(['./result/', dataset, '.mat']);
else load(['./result/', dataset, '_raw.mat']);
end
result_raw = result;
[l, ~] = size(result_raw);
clear result
classes = [1,3,6,7];
for frame = 1:l
    result{frame} = zeros(1,5+length(classes));
    k = 0;
    for j = 1:length(classes)
        [temp, ~] = size(result_raw{frame,classes(j)});
        for m = 1:temp
            k = k + 1;
            result{frame}(k,1:4) = result_raw{frame,classes(j)}(m,1:4);
            result{frame}(k,5) = 1;
            result{frame}(k,j+5) = result_raw{frame,classes(j)}(m,5);
        end
    end
end
% save(['./processed/',dataset, '.mat'],'result');
end