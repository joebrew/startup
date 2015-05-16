import urllib
import os
import numpy
import pandas as pd
import rpy2.robjects as robjects

# Set working directory
os.chdir('/home/joebrew/Documents/startup')

# Run R code to get link for the day
robjects.r['source']("startup.R")


#####
# INTRO
#####

# Read in today's link
text_file = open('intro.txt', 'r')
lines = text_file.read()
urllib.urlretrieve (lines, "intro.mp3")

#####
# QUOTE OF THE DAY
#####
text_file = open('quote.txt', 'r')
lines = text_file.read()
urllib.urlretrieve (lines, "quote.mp3")

#####
# WEATHER OF THE DAY
#####
text_file = open('weather.txt', 'r')
lines = text_file.read()
urllib.urlretrieve (lines, "weather.mp3")

#####
# SEND OFF
#####
text_file = open('bye.txt', 'r')
lines = text_file.read()
urllib.urlretrieve (lines, "bye.mp3")


# Play
os.system('play intro.mp3')
os.system('play quote.mp3')
os.system('play weather.mp3')
os.system('play bye.mp3')