####################################################################################################
# scriptBatchs.ps1 - File Transfer script
# Date Created:04/30/2020
# Author: Mauro Trevino
#
####################################################################################################



####################################################################################################
# Required to prevent connection closed error.
####################################################################################################
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


####################################################################################################
# Load values from properties file under C:\temp\files\properties\props.txt
####################################################################################################
$AppProps = convertfrom-stringdata (get-content .\properties\properties.txt -raw)
$localrootpath = $AppProps.LOCALROOTPATH
$sourcePath = $AppProps.SOURCEPATH
$destPath = $AppProps.DESTINATIONPATH
$beforeAfterOrBetween=$AppProps.ALLorBEFOREorAFTERorBETWEEN
[datetime]$beforeDate=$AppProps.BEFOREDATE
[datetime]$afterDate=$AppProps.AFTERDATE
[datetime]$betweenDateOld=$AppProps.BETWEENDATEOLD
[datetime]$betweenDateNew=$AppProps.BETWEENDATENEW
$processedfilesPerBatch=$AppProps.PROCESSEDFILESPERBATCH
$afterDateString = ($afterDate).ToString('MM/dd/yyyy')
Add-Content $activitylog " $batchPath - batch path"

# Local Logs
$dateRobo = [datetime]::Today.ToString('MM_dd_yyy')
$dateLogStart = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
$activitylog = $localrootpath + "\logs\$($dateRobo)_activitylog.txt"

$ToNatural= { [regex]::Replace($_, '\d+',{$args[0].Value.Padleft(20)})}
Add-Content $activitylog "$dateLogStart  - START"
$totalCount = (Get-ChildItem $sourcePath | Measure-Object ).Count;
Add-Content $activitylog "Total Number of Files: $totalCount"



####################################################################################################
# FUNCTIONS
####################################################################################################
        function moveFilesAfter(){
            try{

            $totalCountAfter = (Get-ChildItem $sourcePath | Where-Object { $_.LastWriteTime -gt $afterDate } |  Measure-Object ).Count;
            Add-Content $activitylog "Total Number of Files using After Option Date: $totalCountAfter"
            
            $totalNames = (Get-ChildItem $sourcePath | Where-Object { $_.LastWriteTime -gt $afterDate } | Select-Object -ExpandProperty Name | Out-File $localrootpath\fileNames\$($dateRobo)_List-Of-Files.txt -Force );
            $counter = 0;

                     while(  $totalCountAfter -gt 0){

                         $skipFiles = $counter * $processedfilesPerBatch
                         $files = (Get-Content $localrootpath\fileNames\$($dateRobo)_List-of-Files.txt | Select -Skip $skipFiles |  Select -First $processedfilesPerBatch )
                         $counter++

                         $totalCountAfter = $totalCountAfter - $processedfilesPerBatch

                        ## Move items using ROBOCOPY
                        robocopy "$sourcePath" "$destPath" $files /z /MT:16 /LOG+:$localrootpath\logs\$($dateRobo)_RoboCopyLog.txt /NS /NC /NDL /MOV 
                                    
                        #LOGS
                        Add-Content $activitylog "BATCH # $counter"
                        Add-Content $activitylog "Files were moved successfully - $files"

                     }

            }catch{
                Add-Content $activitylog "Error movingFiles : $_.Exception.Message"
            }
        }


        function moveFilesBefore(){
            try{

            $totalCountBefore = (Get-ChildItem $sourcePath | Where-Object { $_.LastWriteTime -lt $beforeDate } | Measure-Object ).Count;
            Add-Content $activitylog "Total Number of Files using Before Option Date: $totalCountBefore"
            
            $totalNames = (Get-ChildItem $sourcePath | Where-Object { $_.LastWriteTime -lt $beforeDate } | Select-Object -ExpandProperty Name | Out-File $localrootpath\fileNames\$($dateRobo)_List-Of-Files.txt -Force );
            $counter = 0;

                 while($totalCountBefore -gt 0){

                         $skipFiles = $counter * $processedfilesPerBatch
                         $files = (Get-Content $localrootpath\fileNames\$($dateRobo)_List-of-Files.txt | Select -Skip $skipFiles |  Select -First $processedfilesPerBatch )
                         $counter++

                         $totalCountBefore = $totalCountBefore - $processedfilesPerBatch

                        ## Move items using ROBOCOPY
                        robocopy "$sourcePath" "$destPath" $files /z /MT:16 /LOG+:$localrootpath\logs\$($dateRobo)_RoboCopyLog.txt /NS /NC /NDL /MOV 
                                    
                        #LOGS
                        Add-Content $activitylog "BATCH # $counter"
                        Add-Content $activitylog "Files were moved successfully - $files"

                     }

            }catch{
                Add-Content $activitylog "Error movingFiles : $_.Exception.Message"
            }
        }


        function moveFilesBetween(){
            try{

            $totalCountBetween = (Get-ChildItem $sourcePath | Where-Object {  $_.lastwritetime -gt $betweenDateOld -AND $_.lastwritetime -lt $betweenDateNew } | Measure-Object ).Count;
            Add-Content $activitylog "Total Number of Files using Between Option Date: $totalCountBetween"
            
            $totalNames = (Get-ChildItem $sourcePath | Where-Object { $_.lastwritetime -gt $betweenDateOld -AND $_.lastwritetime -lt $betweenDateNew } | Select-Object -ExpandProperty Name | Out-File $localrootpath\fileNames\$($dateRobo)_List-Of-Files.txt -Force );
            $counter = 0;

                      while($totalCountBetween -gt 0){

                         $skipFiles = $counter * $processedfilesPerBatch
                         $files = (Get-Content $localrootpath\fileNames\$($dateRobo)_List-of-Files.txt | Select -Skip $skipFiles |  Select -First $processedfilesPerBatch )
                         $counter++

                         $totalCountBetween = $totalCountBetween - $processedfilesPerBatch

                        ## Move items using ROBOCOPY
                        robocopy "$sourcePath" "$destPath" $files /z /MT:16 /LOG+:$localrootpath\logs\$($dateRobo)_RoboCopyLog.txt /NS /NC /NDL /MOV 
                                    
                        #LOGS
                        Add-Content $activitylog "BATCH # $counter"
                        Add-Content $activitylog "Files were moved successfully - $files"

                     }

            }catch{
                Add-Content $activitylog "Error movingFiles : $_.Exception.Message"
            }
        }


        function moveFilesAll(){
            try{
                      $totalCountInner = (Get-ChildItem $sourcePath | Measure-Object ).Count;
                      $totalNames = (Get-ChildItem $sourcePath | Select-Object -ExpandProperty Name | Out-File $localrootpath\fileNames\$($dateRobo)_List-Of-Files.txt -Force );
            
                      $counter = 0;

                      while($totalCountInner -gt 0){

                         $skipFiles = $counter * $processedfilesPerBatch
                         $files = (Get-Content $localrootpath\fileNames\$($dateRobo)_List-of-Files.txt | Select -Skip $skipFiles |  Select -First $processedfilesPerBatch )
                         $counter++

                         $totalCountInner = $totalCountInner - $processedfilesPerBatch

                        robocopy "$sourcePath" "$destPath" $files /z /MT:16 /LOG+:$localrootpath\logs\$($dateRobo)_RoboCopyLog.txt /NS /NC /NDL /MOV

                        #LOGS
                        Add-Content $activitylog "BATCH # $counter"
                        Add-Content $activitylog "Files were moved successfully - $files"
                    }
            }catch{
                Add-Content $activitylog "Error movingFiles : $_.Exception.Message"
            }
        }



    ####################################################################################################
    # CALL FUNCTION DEPENDING WHICH DATE PROPERTY WAS CHOSEN OR IF ALL FILES SHOULD BE PROCESSED
    ####################################################################################################

Function startJob{

    if($beforeAfterOrBetween -like "After"){
        Add-Content $activitylog "Using AFTER date property"
        moveFilesAfter
        $dateLogEnd = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
        Add-Content $activitylog "$dateLogEnd - END"
    }
    elseif($beforeAfterOrBetween -like "Before"){
        Add-Content $activitylog "Using BEFORE date property"
        moveFilesBefore
        $dateLogEnd = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
        Add-Content $activitylog "$dateLogEnd - END"
    }
    elseif($beforeAfterOrBetween -like "Between"){
        Add-Content $activitylog "Using BETWEEN date property"
        moveFilesBetween
        $dateLogEnd = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
        Add-Content $activitylog "$dateLogEnd - END"
    }
    elseif($beforeAfterOrBetween -like "All"){
        Add-Content $activitylog "Using ALL date property"
        moveFilesAll
        $dateLogEnd = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
        Add-Content $activitylog "$dateLogEnd - END"
    }
  }

##########################################################################################################################
# Run code 
##########################################################################################################################
			
    # Start
    startJob 
