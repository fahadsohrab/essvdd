# Ellipsoidal Subspace Support Vector Data Description
This repository is for Ellipsoidal Subspace Support Vector Data Description (ES-SVDD). The codes are provided as .m (matlab) files to be executed in matlab. The codes are provided without any warranty or gurantee. Download the package from [HERE](https://github.com/fahadsohrab/essvdd/archive/main.zip), unzip and add the folder **essvdd-main** to the path in matlab. see **ESSVDDdemo.m** for exmaple usage.


# Requirements 
ES-SVDD requires *LIBSVM for SVDD*. Before executing the codes, make sure that correct version (3.22) of *LIBSVM for SVDD* is installed already. In order to install *LIBSVM for SVDD*  Please download zip file from [HERE](https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/svdd/libsvm-svdd-3.22.zip), put sources into libsvm-3.22 available [HERE](https://www.csie.ntu.edu.tw/~cjlin/libsvm/oldfiles/libsvm-3.22.zip), and make the code. For more details about how to install libsvm, please refer [HERE](https://www.csie.ntu.edu.tw/~cjlin/libsvmtools/#libsvm_for_svdd_and_finding_the_smallest_sphere_containing_all_data)

# Usage 
```text
Possible inputs to essvddtrain()
The first input argument is Training data
other options (input arguments) include

 'maxIter' :Maximim iteraions, Default=100
 'C'       :Value of hyperparameter C, Default=0.1
 'd'       :Data in lower dimension, make sure that input d<D, Default=1
 'eta'     :Used as step size for gradient, Default=0.1
 'psi'     :Regularization term, Default=0 i.e., No regularization term
           :Other options for psi are 1,2,3 (Please refer to paper for more details)
 'upsilon' :Regularization term, Default=0 i.e., No regularization term
           :Other options for upsilon are 1,2,3 (Please refer to paper for more details)
 'B'       :Default=0.1, Controling the importance of regularization term
 'npt'     :1 for Non-linear Projection Trick (NPT)-based non-linear Subspace-SVDD (Default=0, linear)
  's'       :Hyperparameter for the kernel inside NPT (Default=0.001). 
 ```

# Example 
```text
essvddmodel=essvddtrain(Traindata,'C',0.12,'d',2,'eta',0.02,'upsilon',2);
[predicted_labels,accuracy,sensitivity,specificity]=essvddtest(Testdata,testlabels,essvddmodel); 
```


# Citation
If you use any part of this repository in your implementation, consider citing the following papers.
```text
@ARTICLE{essvdd2020sohrab,
  author={F. {Sohrab} and J. {Raitoharju} and A. {Iosifidis} and M. {Gabbouj}},
  journal={IEEE Access}, 
  title={Ellipsoidal Subspace Support Vector Data Description}, 
  year={2020},
  volume={8},
  pages={122013-122025},
  doi={10.1109/ACCESS.2020.3007123}}
  
  @inproceedings{sohrab2018subspace,
  title={Subspace support vector data description},
  author={Sohrab, Fahad and Raitoharju, Jenni and Gabbouj, Moncef and Iosifidis, Alexandros},
  booktitle={2018 24th International Conference on Pattern Recognition (ICPR)},
  pages={722--727},
  year={2018},
  organization={IEEE}
}
```
# Contact
Please contact fahad.sohrab@tuni.fi for any issues.
