function dcm = ROIS_distance(x1, x2, y1, y2, c)
    dpix = sqrt((x1-x2)^2+(y1-y2)^2);        %# calculate distance in pixels
    
    dcm = dpix/c;                          %# convert to cm from inches
    dcm = round(dcm, 1);
end