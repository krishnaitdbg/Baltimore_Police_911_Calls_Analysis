---
title: "BPD_911_Calls_Analysis"
author: "Krishna"
date: "2/4/2019"
output:
  html_document: 
    keep_md: yes
---

## Summary

This Shiny Web App analyzes Baltimore police department 911 calls data. See below for further details.

  1. Data source for this anaylsis is from Baltimore Police Data Gov site.
  2. Baltimore 911 calls data is available from year 2015 to current date and this app can analyze all 
     data depening upon available resources.
  3. This Application helps in answering below questions regarding Baltimore 911 calls data.
     a. What type of 911 calls were made over given period?
     b. How many 911 calls data were made per day over given period?
     c. How many 911 calls data were made per hour over given period?
     d. From which incident location, these 911 calls were made?

## Load necessary libraries


```r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(tidyr)
library(lubridate)
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:base':
## 
##     date
```

```r
library(jsonlite)
```

## Data used for this analysis

Fetch JSON format data from Baltimore 911 calls data gov site.


```r
p911data <- fromJSON(URLencode("https://data.baltimorecity.gov/resource/m8g9-abgb.json?$where=date_trunc_ymd(calldatetime) between '2015-01-01' AND '2019-02-28'&$limit=5000000"),flatten=TRUE) 
dim(p911data)
```

```
## [1] 4176597      12
```

## Understand data and sample data


```r
str(p911data)
```

```
## 'data.frame':	4176597 obs. of  12 variables:
##  $ calldatetime        : chr  "2018-12-08T00:25:00.000" "2018-12-07T18:02:00.000" "2018-12-08T01:45:00.000" "2018-12-07T16:00:00.000" ...
##  $ callnumber          : chr  "P183420050" "P183412302" "P183420234" "P183411928" ...
##  $ description         : chr  "HIT AND RUN" "AUTO ACCIDENT" "COMMON ASSAULT" "BAIL OUT" ...
##  $ district            : chr  "NE" "NE" "CD" "SE" ...
##  $ incidentlocation    : chr  "2800 ROSALIE AV" "6700 PULASKI HY" "0 MARKET PL" "600 S MONTFORD AV" ...
##  $ location_address    : chr  "2800 ROSALIE AV" "6700 PULASKI" "0 MARKET PL" "600 S MONTFORD AV" ...
##  $ location_city       : chr  "BALTIMORE" "HY BALTIMORE" "BALTIMORE" "BALTIMORE" ...
##  $ location_state      : chr  "MD" "MD" "MD" "MD" ...
##  $ priority            : chr  "Low" "Low" "Medium" "High" ...
##  $ recordid            : chr  "4041036" "4040015" "4041169" "4039701" ...
##  $ location.type       : chr  "Point" "Point" NA "Point" ...
##  $ location.coordinates:List of 4176597
##   ..$ : num  -76.6 39.4
##   ..$ : num  -76.5 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.2
##   ..$ : num  -76.5 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : NULL
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.5 39.3
##   ..$ : NULL
##   ..$ : num  -86.8 33.4
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : NULL
##   ..$ : NULL
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : num  -76.7 39.4
##   ..$ : num  -76.5 39.3
##   ..$ : num  -77.5 39.5
##   ..$ : NULL
##   ..$ : num  -76.1 39
##   ..$ : num  -76.6 39.1
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.4
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : NULL
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.9 38.9
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.7 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.7 39.4
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.4
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : num  -76.6 39.3
##   ..$ : NULL
##   ..$ : num  -76.6 39.2
##   .. [list output truncated]
```

```r
head(p911data)
```

```
##              calldatetime callnumber    description district
## 1 2018-12-08T00:25:00.000 P183420050    HIT AND RUN       NE
## 2 2018-12-07T18:02:00.000 P183412302  AUTO ACCIDENT       NE
## 3 2018-12-08T01:45:00.000 P183420234 COMMON ASSAULT       CD
## 4 2018-12-07T16:00:00.000 P183411928       BAIL OUT       SE
## 5 2018-12-08T00:05:00.000 P183420012   Traffic Stop       SE
## 6 2018-12-07T16:16:00.000 P183411975    Private Tow       SE
##          incidentlocation        location_address location_city
## 1         2800 ROSALIE AV         2800 ROSALIE AV     BALTIMORE
## 2         6700 PULASKI HY            6700 PULASKI  HY BALTIMORE
## 3             0 MARKET PL             0 MARKET PL     BALTIMORE
## 4       600 S MONTFORD AV       600 S MONTFORD AV     BALTIMORE
## 5 3000-BLK E FAIRMOUNT AV 3000 BLK E FAIRMOUNT AV     BALTIMORE
## 6         3100 PULASKI HY            3100 PULASKI  HY BALTIMORE
##   location_state      priority recordid location.type location.coordinates
## 1             MD           Low  4041036         Point  -76.55267, 39.36950
## 2             MD           Low  4040015         Point  -76.53685, 39.30575
## 3             MD        Medium  4041169          <NA>                 NULL
## 4             MD          High  4039701         Point  -76.58284, 39.28488
## 5             MD          High  4040993         Point  -76.57466, 39.29335
## 6             MD Non-Emergency  4039745         Point  -76.57301, 39.29558
```

## Explore data


```r
p911data %>% group_by(callyear=substr(calldatetime,1,4)) %>% summarise(n())
```

```
## # A tibble: 5 x 2
##   callyear   `n()`
##   <chr>      <int>
## 1 2015     1071776
## 2 2016     1048633
## 3 2017     1003446
## 4 2018      954487
## 5 2019       98255
```

## Important Links

### Data Source (JSON Format) 

Baltimore 911 Calls json data api end point link is provided below.

https://data.baltimorecity.gov/resource/m8g9-abgb.json

### Source Code

Baltimore 911 Calls analysis Source code is uploaded to Github and link is provided below.

https://github.com/krishnaitdbg/Baltimore_Police_911_Calls_Analysis

### Analysis output 

Shiny web App is uploaded to Shiny server and link is provided below.

https://krishnaitdbg.shinyapps.io/BPolice_911_Call_Data_Analysis/

### Supporting HTML documentation 

https://krishnaitdbg.github.io/Baltimore_Police_911_Calls_Analysis/BPD_911_Calls_Analysis.html

Thank you for the visit.
