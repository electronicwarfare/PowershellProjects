#Pull weather forecast data for the next 7 days from weather.gov as an XML 
#location is based upon the lat longs in the site url.
#borrowed base code from website below
#https://pisquare.osisoft.com/thread/35301-how-do-i-use-pi-connector-for-ufl-to-parse-forecast-future-data?_ga=2.168086115.354682782.1571075528-655294286.1570479063

#******************************************************************************
#this function checks if the output file exists. If so, it is deleted.
Function OutputTest($outputFile){

    If(Test-Path $outputFile){ Remove-Item $outputFile}

}

#****************************************************************************** 
#******************************************************************************
#weather data function
#pulls data from the weather site with the site url.

Function weatherData($siteName, $siteURL){

    #todays date for the outputfile
    $varD = get-date -f "yyyy-MM-dd"

    #sets the output file to a folder named after the site. The xml file from the weather site is then saved as the site name and date.
    #********Make sure to create folders in the main weather folder named after each site, and put in the correct folder path for destination.*********
    $destination = "XXXX_Folder_Path_XXXX" + $siteName + "\" + $siteName + "_" + $varD + ".xml"

    #if the output files exists it is deleted.
    OutputTest $destination

    #data web url 
    $source = $siteURL

    #downloads the data and saves in the output file.
    Invoke-WebRequest $source -OutFile $destination

}

#******************************************************************************
#******************************************************************************
#Main code starts here.

#location name for weather data. Must match site url below. First url is for Miami, etc...

$siteNames = "Miami", "Austin"

#To change the site url, enter coordinates for location of interest.
$siteURLS =@(
    'https://forecast.weather.gov/MapClick.php?lat=25.7617&lon=-80.1918&FcstType=digitalDWML'
    'https://forecast.weather.gov/MapClick.php?lat=30.2672&lon=-97.7431&FcstType=digitalDWML'
    )

#cycle through each and download data. For more sites increase the range (middle value).
For($i = 0; $i -lt 2; $i++){

    
    weatherData $siteNames[$i] $siteURLs[$i]
    #Write-Host $siteNames[$i] + $siteURLs[$i]

    }
