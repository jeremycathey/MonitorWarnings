function RA_GQL_JobMonitoring{
    param($URI, $Creds)
    #Create Auth for Basic API Authentication
    $auth = RA_GetAPIAuth -Creds $Creds
    $headers = @{
        'Content-Type'  = 'application/json';
        'Accept'        = 'application/json';
        'Authorization' = "Basic $auth";
    }
    $endpoint = 'https://' + $URI + '/api/internal/graphql'
    # Get number of vms Protected
    $payload = @{
        "operationName" = "JobMonitoringWithCountByType";
        "query"         = "query JobMonitoringWithCountByType(`$jobState: String!, `$includeLogRelatedJob: Boolean = false, `$jobStatus: String, `$effectiveSlaDomainId: String, `$isFirstFull: Boolean, `$jobType: String, `$objectName: String, `$objectType: String, `$nodeName: String, `$isOnDemand: Boolean, `$sortBy: String, `$sortOrder: String, `$first: Int, `$after: String) {
  jobMonitoring(jobState: `$jobState, includeLogRelatedJob: `$includeLogRelatedJob, jobStatus: `$jobStatus, effectiveSlaDomainId: `$effectiveSlaDomainId, isFirstFull: `$isFirstFull, jobType: `$jobType, objectName: `$objectName, objectType: `$objectType, nodeName: `$nodeName, isOnDemand: `$isOnDemand, sortBy: `$sortBy, sortOrder: `$sortOrder, first: `$first, after: `$after)
                          {
                               nodes {
                                      monitoringId
                                      jobMonitoringState
                                      jobStatus
                                      jobType
                                      objectId
                                      objectType
                                      objectName
                                      locationId
                                      locationName
                                      slaDomainId
                                      slaDomainName
                                      isFirstFullSnapshot
                                      sourceClusterName
                                      retryCount
                                      maximumAttemptsForJob
                                      dataTransferred
                                      objectLogicalSize
                                      dataToTransfer
                                      throughput
                                      eventSeriesId
                                      duration
                                      nodeId
                                      warningCount
                                      isLogTask
                                      isOnDemand
                                      startTime
                                      endTime
                                      lastSuccessfulJobTime
                                      nextJobTime
                                    }
                                    pageInfo {
                                      endCursor
                                      hasNextPage
                                    }
                                  }
                                  countByType(jobState: `$jobState) {
                                    total
                                    archival
                                    backup
                                    conversion
                                    recovery
                                    replication
                                    index
                                    logBackup
                                    logArchival
                                    logReplication
                                    logShipping
                                  }
                                }";
                            
                         "variables" = @{"jobState" = "Success";
                                         "jobStatus" = "SuccessfulWithWarnings";
                                         "sortBy" = "EndTime";
                                         "sortOrder" = "asc";
                                         "first" = 10000;
                                        }
                 }

    $response = Invoke-RestMethod -Method POST -Uri $endpoint -Body $($payload | ConvertTo-JSON -Depth 100) -Headers $headers

    return $response
    }
