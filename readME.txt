
* Unsupervised Semantic Segmentation of Street Scenes From Motion Cues:

- Given an unannotated video sequence of a dynamic scene 

- From fixed viewpoint

- Presenting a set of useful motion features extracted at each pixel by optical flow

- Extracting motion topic models

- Identifying semantically significant regions and landmarks in a complex scene

- Using Latent Dirichlet Allocation (LDA) using Gibbs Sampling

- 2 videos of Virat dataset

- About 1300 frames per video

- K different topic models: We chose K=9

- Features: Motion features + Lab colour features


************ CODE:
- FindFeature.m: 
  extract features for each frame of video and save them in the work space

- docList.m:
  It makes a text-file as input for GibbsLDA++


