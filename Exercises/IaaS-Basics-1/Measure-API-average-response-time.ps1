<#
.SYNOPSIS
    Small script to measure response time when sending multiple requests to the same URL.
.DESCRIPTION
    Small script to measure response time when sending multiple requests to the same URL.
    It sends 10 requests to the same URL concurrently and measured when the request was
    sent and when the response has arrived.

    Run the script first against a single Web-Host (i.e. one VM) and then against the
    load balancer and verify that the response time decrease in average.
.PARAMETER Url
    The URL to be called as a GET request to measure response times.
#>
Param ([string]$Url)

Clear-Host

if (!$Url) {
  $Url = "http://localhost:23675/api/compute/43";
}
$count = 10;


# Workflow to invoke API requests concurrently
workflow measureConcurrentApiCalls {
  param ([string]$url, [int]$CountConcurrentRequests)
  
  $loopTaskIds = @(0) * $CountConcurrentRequests;  # helper variable to allow concurrent execution of foreach loop 'content'

  $responseTimes = @()
  foreach -parallel ($taskId in $loopTaskIds) {
    
    $requestStart = Get-Date;
    $response = Invoke-RestMethod -Uri $url;
    $requestStop = Get-Date;
    $requestRuntime = $requestStop-$requestStart;

    $result = @{
      "Request Start" =$requestStart;
      "Request Runtime"= $requestRuntime;
      "Request Stop" = $requestStop;
    }

    $WORKFLOW:responseTimes += @{
      $taskId = $result
    }
  }
  return $responseTimes
}

# call the workflow
$responseTimes = measureConcurrentApiCalls -url $Url -CountConcurrentRequests $count 

# compute average time until API requests were anwsered
$avgTime = 0;
foreach ($time in $responseTimes) {
  $avgTime += $time[0]["Request Runtime"]
}
$avgTime = $avgTime.TotalMilliseconds / $count


Write-Host "Average time to answer API request: " $avgTime "msec"
$i = 1;
foreach ($response in $responseTimes) {
  Write-Host "Started request  #"$i.ToString().PadLeft(3) ": " $response[0]["Request Start"]
  Write-Host "Finished request #"$i.ToString().PadLeft(3) ": " $response[0]["Request Stop"]
  Write-Host "Duration request #"$i.ToString().PadLeft(3) ": " $response[0]["Request Runtime"]
  Write-Host "------------------------------"
  ++$i;
}




