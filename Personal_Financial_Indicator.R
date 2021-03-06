#This program is a personal financial Indicator
#Load the financial modelling packages

library(quantmod)
library(quantstrat)
library(TTR)

#Create Dates
initdate <- "1999-01-01"
from <- "2003-01-01"
to <- "2015-12-31"

# Set the timezone
Sys.setenv(TZ = "UTC")

#Set the currency

currency("USD")

#Define a strategy
#Define trade size and initial equity

tradesize <- 1000000
initeq    <- 1000000

#Define name of strategy, portfolio and account

strategy.st <- "firststrat"
portfolio.st <- "firststrat"
account.st <- "firststrat"

#Remove any existing strategy
rm.strat(strategy.st)

# Initialize the portfolio
initPortf(portfolio.st, symbols = "SPY", initDate = initdate, currency = "USD")

# Initialize the account
initAcct(account.st, portfolios = portfolio.st, initDate = initdate, currency = "USD", initEq = initeq)

# Initialize the orders
initOrders(portfolio.st, initDate = initdate)

# Store the strategy
strategy(strategy.st, store = TRUE)

# Create customised indicatior using the David Varadi Oscillator(DVO)
# The DVO attempts to find opportunities to buy a temporary dip and sell in a temporary uptrend. 
#In addition to obligatory market data, an oscillator function takes in two lookback periods.

# Delare the DVO function
DVO <- function(HLC, navg = 2, percentlookback = 126) {
  
  # Compute the ratio between closing prices to the average of high and low
  ratio <- Cl(HLC)/((Hi(HLC) + Lo(HLC))/2)
  
  # Smooth out the ratio outputs using a moving average
  avgratio <- SMA(ratio, n = navg)
  
  # Convert ratio into a 0-100 value using runPercentRank()
  out <- runPercentRank(avgratio, n = percentlookback, exact.multiplier = 1) * 100
  colnames(out) <- "DVO"
  return(out)
}

# Add the DVO indicator to the strategy
add.indicator(strategy = strategy.st, name = "DVO", 
              arguments = list(HLC = quote(HLC(mktdata)), navg = 2, percentlookback = 126),
              label = "DVO_2_126")

# Use applyIndicators to test out the indicator
test <- applyIndicators(strategy = strategy.st, mktdata = OHLC(SPY))

# Subset your data between Sep. 1 and Sep. 5 of 2013
test_subset <- test["2013-09-01/2013-09-05"]