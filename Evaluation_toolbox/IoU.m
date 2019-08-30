function score = IoU(box1, box2)
% bounding boxes: [x1 y1 x2 y2]
x = min(box1(3),box2(3))-max(box1(1), box2(1));
y = min(box1(4),box2(4))-max(box1(2), box2(2));
if x > 0 && y > 0
    I = x*y;
    U = (box1(3)-box1(1))*(box1(4)-box1(2)) + (box2(3)-box2(1))*(box2(4)-box2(2)) - I;
    score = I/U;
else
    score = 0;
end
end
