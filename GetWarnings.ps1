$ScriptPath = 'G:\My Drive\Scripts\Powershell\GetWarnings\'
$CSVPath = $ScriptPath + 'logs\MonitoringWarnings.csv'

################################################
# Importing All Functions
################################################
$FunctionsDirectory = $ScriptPath + 'RA_Functions\'
$Functions = Get-ChildItem -Path $FunctionsDirectory -Recurse
# Adding each function
ForEach ($Function in $Functions)
{
# Setting path
$FullFunctionPath = $Function.FullName
# Importing
. $FullFunctionPath
}
################################################

#Connect with Rubrik Cluster Using Username/Password (Basic Auth)
$ConnectionInfo = RA_Connect_Creds -ScriptPath $ScriptPath

#<#
    #Call functino to get jobs that have status of Failure
    $JMResults = RA_GQL_JobMonitoring -URI $Connectioninfo.server -Creds $ConnectionInfo.creds
    $JMResultsCount = $JMResults.data.jobMonitoring.nodes.Count

    $JMResultsCount = $JMResultsCount - 1
    $JMEventIDCount = 0
    $JMEventID = @()
    Do{
        $JMEventID += $JMResults.data.jobMonitoring.nodes[$JMResultsCount].eventSeriesId
        #Write-Host $JMEventID[$JMEventIDCount]
        $JMResultsCount = $JMResultsCount - 1
        $JMEventIDCount = $JMEventIDCount + 1
       }while($JMresultsCount -ge 0)
    $JMEventIDCount = $JMEventIDCount - 1

    #Create CSV file for exporting events
    $newcsv = {} | Select "Time","EventSeriesID","TaskType", "ObjectType", "ObjectName", "ObjectID", "Warning" | Export-Csv $CSVPath -NoTypeInformation
    $csvfile = Import-Csv $CSVPath

Do{
    #Take Job Monitoring Event and pass Event Series ID to RA_GetEventSeriresInfo to return the reason, message, and remedy for the Warning
    $ES_Event = RA_GetEventSeriesInfo -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -EventSeriesID $JMEventID[$JMEventIDCount]
    #Convert the return from JSON to assign into variables below
    $ES_EventDetailsCount = $ES_Event.eventDetailList.Count
    $ES_EventDetailsCount = $ES_EventDetailsCount -1
    $ES_EventDetails_FirstRecord = 0
    Do{
        $ES_Event_Details = $ES_Event.eventDetailList[$ES_EventDetailsCount].eventInfo | ConvertFrom-Json

        if($ES_Event.eventDetailList[$ES_EventDetailsCount].eventStatus -eq "Warning"){
            if($ES_EventDetails_FirstRecord -eq 0){
            Write-Host "Processing Event $JMEventIDCount"
            $csvfile.Time = $ES_Event.startTime
            $csvfile.EventSeriesID = $ES_Event.eventSeriesId
            $csvfile.TaskType = $ES_Event.taskType
            $csvfile.ObjectType = $ES_Event.objectType
            $csvfile.ObjectName = $ES_Event.objectName
            $csvfile.ObjectID = $ES_Event.objectId

            $ES_EventDetails_FirstRecord = 1
            }
        $csvfile.Warning = $ES_Event_Details.message
        $csvfile | Export-Csv -Path $CSVPath -NoTypeInformation -Append
        }
        $ES_EventDetailsCount = $ES_EventDetailsCount -1
    }while($ES_EventDetailsCount -ge 0)
    $JMEventIDCount = $JMEventIDCount - 1
}while($JMEventIDCount -ge 0)
#>
