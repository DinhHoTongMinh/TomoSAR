## TomoSAR for PSDS and ComSAR processing
We exploited the SNAP as an InSAR processor and StaMPS as an InSAR time series tool. 
These tools are open source so that people can apply our PSDS and ComSAR methods for 
an end-to-end processing chain.

TomoSAR can work on stripmap, spotlight, or TOPS SAR data as long as they were exported by SNAP.
For more pratical, we provide a workflow on TOPS Sentinel-1 data. 

## Workflow end-to-end tutorial for Sentinel-1
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
   
   It should give you the differential phase (*.psds or *.comp) and single look complex (*.psar or *.csar) products. 
   
   In terminal, run 'mt_prep_snap_psds' or 'mt_prep_snap_comsar'    
	
4. Time series InSAR analysis using StaMPS

   You can follow the tutorial here: 
   
   Persistent Scatterer InSAR time series with StaMPS in Window and Unix, Session 3/3
   
   https://youtu.be/a1WlsoRrlrU   
  
## Notes on performance
The code is optimized, but it is heavy on memory use. 
By default, the code will load all data for processing. 
Future to do work will focus on data structure for optimizing memory requirements. 
At the moment, it is better to crop image to the area of interest for local analysis. 

## Community Support
Please join and post your question in this group https://www.facebook.com/groups/RadarInterferometry to have quicker reply.

Author: Dinh Ho Tong Minh (INRAE) and Yen Nhi Ngo, Jan. 2022 