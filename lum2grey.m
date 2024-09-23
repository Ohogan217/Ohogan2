function BL = lum2grey(LUM,varargin)

% Converts luminance values to computer brightness levels for the monitor 
% inside the UCD EEG booth. Luminance values beyond the computers capacity
% will all be assigned a brightness level of 255. Values below 0 will be
% assigned 0.
% 
% This is implemented as a lookup table. Varargin takes any additional
% arguments (e.g. parameters from previous versions of lum2grey) and
% ignores them for backward compatibility.

ND = ndims(LUM);
extradim = ND+1;

lums = [0.144000000000000;0.170000000000000;0.196000000000000;0.222000000000000;0.248000000000000;0.274000000000000;0.316000000000000;0.358000000000000;0.400000000000000;0.442000000000000;0.484000000000000;0.540000000000000;0.596000000000000;0.652000000000000;0.708000000000000;0.764000000000000;0.839200000000000;0.914400000000000;0.989600000000000;1.06480000000000;1.14000000000000;1.23600000000000;1.33200000000000;1.42800000000000;1.52400000000000;1.62000000000000;1.73800000000000;1.85600000000000;1.97400000000000;2.09200000000000;2.21000000000000;2.34800000000000;2.48600000000000;2.62400000000000;2.76200000000000;2.90000000000000;3.07200000000000;3.24400000000000;3.41600000000000;3.58800000000000;3.76000000000000;3.94400000000000;4.12800000000000;4.31200000000000;4.49600000000000;4.68000000000000;4.89600000000000;5.11200000000000;5.32800000000000;5.54400000000000;5.76000000000000;6;6.24000000000000;6.48000000000000;6.72000000000000;6.96000000000000;7.24000000000000;7.52000000000000;7.80000000000000;8.08000000000000;8.36000000000000;8.65800000000000;8.95600000000000;9.25400000000000;9.55200000000000;9.85000000000000;10.1860000000000;10.5220000000000;10.8580000000000;11.1940000000000;11.5300000000000;11.8660000000000;12.2020000000000;12.5380000000000;12.8740000000000;13.2100000000000;13.5980000000000;13.9860000000000;14.3740000000000;14.7620000000000;15.1500000000000;15.5500000000000;15.9500000000000;16.3500000000000;16.7500000000000;17.1500000000000;17.5560000000000;17.9620000000000;18.3680000000000;18.7740000000000;19.1800000000000;19.6440000000000;20.1080000000000;20.5720000000000;21.0360000000000;21.5000000000000;21.9960000000000;22.4920000000000;22.9880000000000;23.4840000000000;23.9800000000000;24.5000000000000;25.0200000000000;25.5400000000000;26.0600000000000;26.5800000000000;27.1360000000000;27.6920000000000;28.2480000000000;28.8040000000000;29.3600000000000;29.9600000000000;30.5600000000000;31.1600000000000;31.7600000000000;32.3600000000000;32.9080000000000;33.4560000000000;34.0040000000000;34.5520000000000;35.1000000000000;35.6120000000000;36.1240000000000;36.6360000000000;37.1480000000000;37.6600000000000;38.4733333333333;39.2866666666667;40.1000000000000;40.8066666666667;41.5133333333333;42.2200000000000;42.8733333333333;43.5266666666667;44.1800000000000;44.8600000000000;45.5400000000000;46.2200000000000;46.9666666666667;47.7133333333333;48.4600000000000;49.2333333333333;50.0066666666667;50.7800000000000;51.4866666666667;52.1933333333333;52.9000000000000;53.7400000000000;54.5800000000000;55.4200000000000;56.1400000000000;56.8600000000000;57.5800000000000;58.3400000000000;59.1000000000000;59.8600000000000;60.6200000000000;61.3800000000000;62.1400000000000;62.9066666666667;63.6733333333333;64.4400000000000;65.1333333333333;65.8266666666667;66.5200000000000;67.3200000000000;68.1200000000000;68.9200000000000;69.6600000000000;70.4000000000000;71.1400000000000;71.8600000000000;72.5800000000000;73.3000000000000;74.1666666666667;75.0333333333333;75.9000000000000;76.6866666666667;77.4733333333333;78.2600000000000;79.0466666666667;79.8333333333333;80.6200000000000;81.3133333333333;82.0066666666667;82.7000000000000;83.4933333333333;84.2866666666667;85.0800000000000;85.7466666666667;86.4133333333333;87.0800000000000;87.7466666666667;88.4133333333333;89.0800000000000;89.7733333333333;90.4666666666667;91.1600000000000;92;92.8400000000000;93.6800000000000;94.3666666666667;95.0533333333333;95.7400000000000;96.4933333333333;97.2466666666667;98;98.6200000000000;99.2400000000000;99.8600000000000;100.526666666667;101.193333333333;101.860000000000;102.480000000000;103.100000000000;103.720000000000;104.426666666667;105.133333333333;105.840000000000;106.433333333333;107.026666666667;107.620000000000;108.433333333333;109.246666666667;110.060000000000;110.786666666667;111.513333333333;112.240000000000;112.900000000000;113.560000000000;114.220000000000;114.886666666667;115.553333333333;116.220000000000;116.866666666667;117.513333333333;118.160000000000;118.820000000000;119.480000000000;120.140000000000;120.793333333333;121.446666666667;122.100000000000;122.820000000000;123.540000000000;124.260000000000;124.720000000000;125.180000000000;125.640000000000;126.236296296296;126.832592592593;127.428888888889;127.928148148148;128.427407407407;128.926666666667];
lums = reshape(lums,[ones(1,ND) length(lums)]);

lums_gt = bsxfun(@ge,LUM,lums);
BL = sum(lums_gt,extradim);

end