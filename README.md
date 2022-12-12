## Image Understanding Final Project

### Methodalogy
- Paper & Code source
https://github.com/abenhamadou/Self-Supervised-Endoscopic-Image-Key-Points-Matching  
https://www.sciencedirect.com/science/article/pii/S0957417422017274  

### User Instruction
### Training & testing Part
- running in Ubuntu & Python
- actiavte virtual environment with anaconda:  
source activate crns---self-sup-image-matching  
- sequence of running through the process:  
1. generate triplet loss  
2. training  
3. validation(with orignal dataset) -> absolute accuracy  
3. estimation(with own dataset) -> relative accuracy  
4. matching demo -> frames & gifs  
- Run in terminal:  
python run_xxx.py  

### Evaluation with Matlab
- dataset source  
https://data.mendeley.com/datasets/cd2rtzm23r/1  

- Evaluation Method  
- Extract Feature  
run SIFT extraction with .m file, it will generate frames reshape to [720,676], and corresponding feature matches coordinates.  
- Evaluate Accuracy and Total Distance  
run Pose Estimation .m file to get accuracy of output from model, the result will be recorded in .txt file  
- 3d reconstruction  
run Reconstruction .m file, it will output the pointcloud file.(on progress) Currently, it takes just two consecutive frames.  


