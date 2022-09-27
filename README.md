# UPPER
Three-Dimensional Unsupervised Probabilistic Pose Reconstruction (3D-UPPER) for Freely Moving Animals

1-	Data Discovery: It shows how many percent of data is missing and if the user demand, it can be removed. (input: Data 3D; output: Figures). 
2-	The Eigen Poses Converge: the function shows the minimum number of poses users need for statical shape model similar to Fig 3a and 3d.  (input: Data 3D, Threshold of Eigen pose, Threshold of Outliers; output: Figures). 
Please change the number of body points and link between body points based on your tracked data in function mouse_plotting. 
3-	3D-UPPER estimate the statical shape model: estimation of Statical shape model (input: 3D data, threshold of eigen pose; output: Estimate mean RANSAC, Mean pPCA, Covariance matrix, Eigen vectors, Eigen values). This step is based on user demand and 3D-UPPER full has this part inside.
4-	3D-UPPER full (input: Raw data, Threshold of Outliers, Estimate mean RANSAC, Covariance matrix, Eigen vectors, Eigen values; output: Reconstructed data).
In each folder there is main file, the main file should run to see the results. 


