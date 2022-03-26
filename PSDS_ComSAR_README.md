## TomoSAR for PSDS and ComSAR processing
We exploited the SNAP/ISCE as an InSAR processor and StaMPS as an InSAR time series tool. 
These tools are open source so that people can apply our PSDS and ComSAR methods for 
an end-to-end processing chain.

TomoSAR can work on stripmap, spotlight, or TOPS SAR data as long as they were exported by SNAP/ISCE.
For more pratical, we provide a workflow on TOPS Sentinel-1 data. 

## Workflow end-to-end tutorial for Sentinel-1 using SNAP
0. Download a good Sentinel-1 data for time series analysis

1. Prepare a reference image using SNAP to better control the area

   You can follow the tutorial here: 
   
   Sentinel-1 InSAR processing workflow with SNAP, Session 1/3
   
   https://youtu.be/5a5gBPA9Gbk
   
2. Prepare a time series SAR data 

   You can follow the tutorial here: 
   
   SNAP2StaMPS – Data preparation for StaMPS PSInSAR processing with SNAP, Session 2/3   

   https://youtu.be/HzvvJoDE8ic
   
3. PSDS and/or ComSAR processing

   The code is available in TomoSAR/Tomography/scripts
   
   Modify your parameters in Parameter_input.m   
   
   Run PSDS_main.m in matlab
   
   It should give you the differential phase (\*.psds or \*.comp) and single look complex (\*.psar or \*.csar) products. 
   
   In terminal, run 'mt_prep_snap_psds' or 'mt_prep_snap_comsar'    
	
4. Time series InSAR analysis using StaMPS

   You can follow the tutorial here: 
   
   Persistent Scatterer InSAR time series with StaMPS in Window and Unix, Session 3/3
   
   https://youtu.be/a1WlsoRrlrU   
  
## Workflow end-to-end tutorial for Sentinel-1 using ISCE
0. Download a good Sentinel-1 data for time series analysis

1. Prepare a time series SAR data using 'stackSentinel.py' 

   You can follow the tutorial here: to be prepare

2. Export to StaMPS using 'make_single_reference_stack_isce' 

   You can follow the tutorial here: to be prepare   
   
3. PSDS and/or ComSAR processing

   The code is available in TomoSAR/Tomography/scripts
   
   Modify your parameters in Parameter_input.m   
   
   Run PSDS_main.m in matlab
   
   It should give you the differential phase (\*.psds or \*.comp) and single look complex (\*.psar or \*.csar) products. 
   
   In terminal, run 'mt_prep_isce_psds' or 'mt_prep_isce_comsar'    
	
4. Time series InSAR analysis using StaMPS

   You can follow the tutorial here: 
   
   Persistent Scatterer InSAR time series with StaMPS in Window and Unix, Session 3/3
   
   https://youtu.be/a1WlsoRrlrU     
  
## Notes on performance
The code is optimized, but it is heavy on memory use. By default, the code will load all data for processing.
A rough approximation for PSDS RAM requirement is 1.5\*Nslc\*Nslc\*Nline\*Nwidth/2.7e8 (GB). Please try more images and smaller sizes for local analysis.  

ComSAR is much friendly Big Data processing. A rough approximation for ComSAR RAM requirement is 0.3\*Nslc\*Nslc\*Nline\*Nwidth/2.7e8 (GB). 
For example, 200 images of 500x2000 size, 220 GB is for PSDS, but for ComSAR it requires only 45 GB.  

For a large area, if you are interested in TomoSAR for your scientific research (i.e 200 images of 3000x20000 size), we can process it free of charge for you (from INSAR_\* of ISCE or SNAP export) under a collaboration, i.e., co-author a scientific article.
Please feel free to contact us (dinh.ho-tong-minh at inrae.fr).

## Community Support
Please join and post your question in this group https://www.facebook.com/groups/RadarInterferometry to have a quicker reply.

## Acknowledgments
The ComSAR work was supported in part by the Centre National d’Etudes Spatiales/Terre, Ocean, Surfaces Continentales, Atmosphere (CNES/TOSCA) (Project MekongInSAR and BIOMASS-valorisation).

Author: Dinh Ho Tong Minh (INRAE) and Yen Nhi Ngo, Jan. 2022 