Function RA_GetEventSeriesInfo{
    param($URI, $Creds, $EventSeriesID)
 #Create Auth for Basic API Authentication
    $auth = RA_GetAPIAuth -Creds $Creds

    #Create API Header with basic authorization and user input credentials
    $APIHeaders = @{
                'Authorization' = "Basic $auth"
                }
    $Address = 'https://' + $URI
    #Create $Address to simplify Uri calls
        $ES_params = @{
        Uri = $Address + '/api/v1/event_series/' + $EventSeriesID
        Headers = $APIHeaders
        Method = 'GET'
        ContentType = 'application/json'
        }
        $ES_Call = Invoke-RestMethod @ES_params

        return $ES_Call
}