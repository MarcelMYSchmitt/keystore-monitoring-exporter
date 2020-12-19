Param(
    [Parameter(Mandatory = $True)]
    [string]
    $KEYSTOREPASSWORD
)


#importing module
Import-Module .\PrometheusExporter

#definition of metric name
$KAFKA_CERT_EXTPIRATION_IN_DAYS = New-MetricDescriptor -Name "KAFKA_CERT_EXTPIRATION_IN_DAYS" -Type gauge -Help "Days until cert is not valid anymore."


#converting months to numbers
Function MonthToInt($Month) {

  $monthInNumber=0
  
  if($month -eq "Jan") {
    $monthInNumber="01"
  }

  if($month -eq "Feb") {
    $monthInNumber="02"
  }

  if($month -eq "Mar") {
    $monthInNumber="03"
  }

  if($month -eq "Apr") {
    $monthInNumber="04"
  }

  if($month -eq "May") {
    $monthInNumber="05"
  }
  
  if($month -eq "Jun") {
    $monthInNumber="06"
  }  

  if($month -eq "Jul") {
    $monthInNumber="07"
  }

  if($month -eq "Aug") {
    $monthInNumber="08"
  }

  if($month -eq "Sep") {
    $monthInNumber="09"
  } 
  
  if($month -eq "Oct") {
    $monthInNumber="10"
  }

  if($month -eq "Nov") {
    $monthInNumber="11"
  }
  
  if($month -eq "Dec") {
    $monthInNumber="12"
  }
    
  return $monthInNumber
}

#read java keystore file - has to be mounted, when running in Docker or Kubernetes
Function Collector () {

  #try to get the line "Valid from: Mon Oct 26 10:01:38 GMT 2020 until: Sun Jan 24 10:01:38 GMT 2021"
  $until = keytool -list -v -keystore ./keystore/keystore.jks -storepass $KEYSTOREPASSWORD | Select-String -Pattern 'until:' 
  $array = $until -split ' '

  #get only day
  $day = $array[11]
  Write-Host "Day:" $day

  #get only month
  $month = MonthToInt -Month $array[10]
  Write-Host "Month:" $month

  #get only year
  $year = $array[14]
  Write-Host "Year:" $year

  #calculating days left by using the days from keystore and the days from current date
  $completeDateRaw = $day+"/"+$month+"/"+$year
  $endDateOfCertificate = [datetime]::ParseExact($completeDateRaw,"dd/MM/yyyy",$Null)
  Write-Host "End date of certificate:" $endDateOfCertificate   
  
  $todaysDateRaw = (Get-Date).ToString('dd/MM/yyyy')
  $todaysDate = [datetime]::ParseExact($todaysDateRaw,"dd/MM/yyyy",$Null)
  Write-Host "Todays date:" $todaysDate   

  $timespan = NEW-TIMESPAN -Start $todaysDate -End $endDateOfCertificate
  $daysLeft = $timespan.Days
  Write-Host "Days left until expiration:" $daysLeft


  @(
    New-Metric -MetricDesc $KAFKA_CERT_EXTPIRATION_IN_DAYS -Value $daysLeft -Labels ("all")
  )
}

#let's get started
try {
  #starting metric server on port 9700
  $exp = New-PrometheusExporter -Port 9700
  Register-Collector -Exporter $exp -Collector $Function:Collector
  $exp.Start()
	
} catch{
  Write-Host "Something went wrong."
}