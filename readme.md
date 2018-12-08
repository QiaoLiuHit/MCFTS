
**Deep Convolutional Neural Networks for Thermal Infrared Object Tracking **
![Alt text](./images/MCFTS_framework.jpg)
## Abstract
We propose a correlation filter based ensemble tracker with multi-layer convolutional features for thermal infrared tracking (**MCFTS**). Firstly, we use pre-trained convolutional neural networks to extract the features of the multiple convolution layers of the thermal infrared target. Then, a correlation filter is used to construct multiple weak trackers with the corresponding convolution layer features. These weak trackers give the response maps of the target’s location. Finally, we propose an ensemble method that coalesces these response maps to get a stronger one. Furthermore, a simple but effective scale estimation strategy is exploited to boost the tracking accuracy. 
## Step by step to run demo
1. Please download the VGG-NET-19 mat file using the link https://uofi.box.com/shared/static/kxzjhbagd6ih1rf7mjyoxn2hy70hltpl.mat or using the link if you are in China http://pan.baidu.com/s/1kU1Me5T , and then, put it into the folder `cnnnet`.

> Note that this mat file is compatile with the MatConvNet-1beta8 used in this work, if you download the mat file from http://www.vlfeat.org/matconvnet/models/imagenet-vgg-verydeep-19.mat.
> please pay attention to the version compatibility. You may need to  modify some names of fields in each convolutional layer.

2. Using the preCompiled Matconvnet (not recommended) or Compile yourself Matconvnet using Matlab in the command window.
```
>>cd matconvnet1.08
>>addpath matlab
>>vl_compilenn('enableGpu', true)
or
>>vl_compilenn('enableGpu', true, ...
'cudaRoot','C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0', ...
'cudaMethod', 'nvcc') % for windows
```
Waiting the notification of success. More information about Matconvnet can be found at http://www.vlfeat.org/matconvnet/install/
3. Run `runAll_vottir.m` to test the demo sequences. 
## Results on VOT-TIR2016
You can download the results in [here](https://drive.google.com/open?id=141ZpogrNkEmGLykHPikkp4m-MW-Cne3h).
## Others
If you find the code helpful in your research, please consider citing:
```
@article{liu2017deep,
  title={Deep convolutional neural networks for thermal infrared object tracking},
  author={Liu, Qiao and Lu, Xiaohuan and He, Zhenyu and Zhang, Chunkai and Chen, Wen-Sheng},
  journal={Knowledge-Based Systems},
  volume={134},
  pages={189--198},
  year={2017}
}
```
Feedbacks and comments are welcome! 
Feel free to contact us via liuqiao.hit@gmail.com or liuqiao@stu.hit.edu.cn
