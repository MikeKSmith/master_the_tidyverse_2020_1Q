#' ---
#' title: "Do you need to pivot?"
#' author: "Mike K Smith"
#' date: "27/11/2019"
#' output: html_document
#' ---
#' 
## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(tidyverse)

#' 
#' ## Is there Information in your column headers?
#' I've been asked a couple of times this week how to employ row-wise functions
#' in the tidyverse. In both cases the colleagues have had data where there is
#' information implied in the column headers / names. So for example, in a mock 
#' dataset, these column headers imply the amount of compound dissolved at 10, 30 
#' and 60 minutes. 
#' 
#' ***Their question:*** "How do I apply a function across columns, making it generic
#' so that if we get future data columns for additional time slots, the code will
#' still work?"
#' 
## ------------------------------------------------------------------------
myData <- tribble(
  ~ID, ~d10, ~d30, ~d60,
  1, 0.1, 0.1, 0.2,
  2, 0.2, 0.2, 0.4,
  3, 0.3, 0.3, 0.6)

myData

#' 
#' ## Remember the principles of tidy data
#' 
## ---- echo=FALSE---------------------------------------------------------
#knitr::include_graphics("exercises/tidy-1.png")

#'   
#' In this case there's information (data) in the column headers that should 
#' be transformed into a variable, in this case: ***TIME***. To work most 
#' effectively with the tidyverse, we should bring the information out of the 
#' column header and create a new variable called `time` containing that 
#' information. We do this by "pivoting" the data, from wide to long. 
#'   
#' ## Pivot column headers into a new variable
#' We want to retain the ID column since this identifies the sample that 
#' has been analysed. So when we pivot, we pivot all columns ***except*** ID.
#' We use the information in the column headers to form a new column called `time`
#' and the values in those columns are brought into a new column called "value".
#' We can extract the time information out of the column headers by extracting
#' the numeric values after the "d" and parsing these as double-precision numeric
#' values (because there might be decimal times in a future dataset).
#' 
## ------------------------------------------------------------------------
myNewData <- myData %>%
  pivot_longer(-ID, names_to="time",values_to="value") %>%
  mutate(time = parse_double(substring(time,2,)))
myNewData

#' 
#' 
#' From here we can apply functions to summarise across time, compare values etc.
#' 
#' In particular we might want to compare values at each time point against a 
#' reference value. There's a useful function as part of dplyr called `case_when` 
#' which is a better form of an "ifelse" function.
#' 
## ------------------------------------------------------------------------
myNewData %>%
  mutate(comparison = case_when(time==10 ~ value>=0.1,
                                time==30 ~ value>=0.2,
                                time==60 ~ value>=0.3,
                                TRUE ~ NA)) %>%
  group_by(ID) %>%
  summarise(sum = sum(comparison)) %>%
  mutate(pass = sum==3)

#' 
#' Even better, you can create a second (small) dataset that provides the conditions (pass conditions
#' at various times, then you can merge this in, which gets rid of the need for 
#' the `case_when` function, as the comparison values are merged to the correct
#' time values.
#' 
## ------------------------------------------------------------------------
passConditions <- tribble(
  ~time, ~passValue,
  10, 0.1,
  20, 0.15, 
  30, 0.2,
  45, 0.25,
  60, 0.3)

myNewData %>%
  left_join(passConditions) %>%
  mutate(comparison = value >= passValue) %>%
  group_by(ID) %>%
  summarise(sum = sum(comparison)) %>%
  mutate(pass = sum==3)

#' 
