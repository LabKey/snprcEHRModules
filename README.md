## Summary
This repository contains all the modules required for the Southwest National Primate Research Center (SNPRC) Total Animal Care (TAC) LabKey server, a system for managing and reporting on electronic health records (EHR) and related research data for the SNPRC primate colony. The server helps the center gain insight into combined lab, clinical and operational information; meet regulatory requirements; and coordinate the activities required to support animal care and research projects.

<a name="modules"></a>
## Modules
1. snprc_ehr: The main EHR module for managing primate care
2. snprc_genetics: Tracks primate genetic data
3. snprc_scheduler: (In development) Coordinates research project schedules
4. snprc_r24: Collaboration project with Wisconsin National Primate Research Center (WNPRC)

<a name="setUp"></a>
## Developer Set Up
1. Clone this repository into the externalModules directory of your LabKey project.  
1. Edit your project settings.gradle file to build the externalModules/snprcEHRModules directory.
1. Build the module with either gradle command 
    * gradlew deployapp 
    * gradlew :externalModules:snprcEHRModules deployModule
