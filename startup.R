library(qdap)
library(weatherData)
setwd('/home/joebrew/Documents/startup')

# Define birthday and life expectancy
birth <- as.Date('1985-11-07')
expected_survival <- 90

# Calculate some basic lived / left-to-live numbers
today <- Sys.Date()
death <- as.Date(birth) + (expected_survival * 365)
lived <- as.numeric(today - birth)
percent <- round(100 * as.numeric(lived) / (expected_survival * 365.25))
left <- as.numeric((death - today) / 365.25)

# Define times
hour <- as.numeric(substr(Sys.time(), 12, 13))
minute <- as.numeric(substr(Sys.time(), 15,16))

time <- ifelse(hour > 3 & hour < 12,
               'morning',
               ifelse(hour < 17,
                      'afternoon',
                      ifelse(hour < 20,
                             'evening',
                             'night')))

# Set random seed
seed <- round((as.numeric(format(today, '%m')) + 
                 as.numeric(format(today, '%y')) * 
                 as.numeric(format(today, '%d')))+(minute) *
                as.numeric(format(today, '%d')), digits = 0)
set.seed(seed)

#################
# voicerss.org
#################

# Read in private api key, which you can get here:
# http://www.voicerss.org/api/
con <- file('/home/joebrew/Documents/private/voicerss/api_key.txt')
api_key <- readLines(con)
close(con)

link <- 'http://api.voicerss.org/?'


#####
# Link for introductory text
#####

say <- paste0('good ', 
              time, 
              ' mister brew. this is day number ',
              replace_number(lived + 1),
              '. you have used up ',
              replace_number(percent),
              ' percent of your life and you have about',
              replace_number(as.numeric(death-today)),
              ' days of life left. ',
              '       the quote of the day is ')

intro_parameters <- paste0('key=', api_key, 
                     '&src=', say,
                     '&hl=en-gb',
                     '&f=44khz_16bit_mono')
voice_intro <- paste0(link, intro_parameters)

con <-file("intro.txt")
writeLines(voice_intro, con)
close(con)

#####
# Link for quote of the day
#####

quotes <- read.delim('Quotes.txt', header = FALSE, sep = ',',
                     stringsAsFactors = FALSE)$V1
quote <- sample(quotes, 1)


quote_parameters <- paste0('key=', api_key, 
                           '&src=', gsub("'", "", quote),
                           '&hl=en-us',
                           '&f=44khz_16bit_mono')
voice_quote <- paste0(link, quote_parameters)

con <-file("quote.txt")
writeLines(voice_quote, con)
close(con)

#####
# Link for closing text (weather)
#####
weather <- getDetailedWeather(station_id = 'GNV',
                              date = today,
                              opt_all_columns = TRUE)
weather <- weather[nrow(weather),]

weather_hour <- replace_number(substr(weather$Time, 12, 13))
weather_minute <- replace_number(substr(weather$Time, 15, 16))
weather_say <- paste0('at ',
                      replace_number(weather$TimeEDT),
                      '   it was ',
                      replace_number(weather$TemperatureF),
                      '  degrees ')
   
#                       'the humidity was at ',
#                       replace_number(weather$Humidity),
#                       ' percent and the conditions were ',
#                       weather$Conditions,
#                       '  with wind from the ',
#                       weather$Wind_Direction, 
#                       ' at ',
#                       replace_number(weather$Wind_SpeedMPH),
#                       ' miles per hour '
#                       )
weather_parameters <- paste0('key=', api_key, 
                           '&src=', weather_say,
                           '&hl=en-gb',
                           '&f=44khz_16bit_mono')
voice_weather <- paste0(link, weather_parameters)

con <-file("weather.txt")
writeLines(voice_weather, con)
close(con)

#####
# Link for send-off
#####

words <- read.csv('words.csv', stringsAsFactors = FALSE)
positives <- words$word[which(words$pos == 'adjective' &
                               words$sentiment == 'positive' &
                                !grepl('LY', words$word))]
positive <- sample(positives, 1)

negatives <- words$word[which(words$pos == 'adjective' &
                               words$sentiment == 'negative' &
                                !grepl('LY', words$word))]
negative <- sample(negatives, 2)

bye <- paste0('sometimes life can be ',
              negative[1], ' and ', negative[2],
              '.  at least make today ', positive)

bye_parameters <- paste0('key=', api_key, 
                           '&src=', bye,
                           '&hl=en-gb',
                           '&f=44khz_16bit_mono')
bye_quote <- paste0(link, bye_parameters)

con <-file("bye.txt")
writeLines(bye_quote, con)
close(con)
