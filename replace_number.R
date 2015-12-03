# Replace Numbers With Text Representation
replace_number  <-
function(text.var, num.paste = TRUE, remove = FALSE) {

    if (remove) return(gsub("[0-9]", "", text.var))

    ones <- c("zero", "one", "two", "three", "four", "five", "six", "seven", 
        "eight", "nine") 

    num.paste <- ifelse(num.paste, "separate", "combine")
 
    unlist(lapply(lapply(gsub(",([0-9])", "\\1", text.var), function(x) {
            if (!is.na(x) & length(unlist(strsplit(x, 
                "([0-9])", perl = TRUE))) > 1) {
                num_sub(x, num.paste = num.paste)
            } else {
                x
            }
        }
    ), function(x) mgsub(0:9, ones, x)))
    
}

## Helper function to convert numbers
numb2word <- function(x){ 
    helper <- function(x){ 
        digits <- rev(strsplit(as.character(x), "")[[1]]) 
        nDigits <- length(digits) 
        if (nDigits == 1) as.vector(ones[digits]) 
        else if (nDigits == 2) 
            if (x <= 19) as.vector(teens[digits[1]]) 
                else trim(paste(tens[digits[2]], 
    Recall(as.numeric(digits[1])))) 
        else if (nDigits == 3) trim(paste(ones[digits[3]], "hundred", 
            Recall(makeNumber(digits[2:1])))) 
        else { 
            nSuffix <- ((nDigits + 2) %/% 3) - 1 
            if (nSuffix > length(suffixes)) stop(paste(x, "is too large!")) 
            trim(paste(Recall(makeNumber(digits[ 
                nDigits:(3*nSuffix + 1)])), 
                suffixes[nSuffix], 
                Recall(makeNumber(digits[(3*nSuffix):1])))) 
            } 
        } 
    trim <- function(text){ 
        gsub("^\ ", "", gsub("\ *$", "", text)) 
        } 
    makeNumber <- function(...) as.numeric(paste(..., collapse="")) 
    opts <- options(scipen=100) 
    on.exit(options(opts)) 
    ones <- c("", "one", "two", "three", "four", "five", "six", "seven", 
        "eight", "nine") 
    names(ones) <- 0:9 
    teens <- c("ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", 
        "sixteen", " seventeen", "eighteen", "nineteen") 
    names(teens) <- 0:9 
    tens <- c("twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", 
        "ninety") 
    names(tens) <- 2:9 
    x <- round(x) 
    suffixes <- c("thousand", "million", "billion", "trillion", "quadrillion",
        "quintillion", "sextillion", "septillion", "octillion", "nonillion",
        "decillion", "undecillion", "duodecillion", "tredecillion", 
        "quattuordecillion") 
    if (length(x) > 1) return(sapply(x, helper)) 
    helper(x) 
}  

## Helper function to sub out numbers
num_sub <- function(x, num.paste) {
    len <- attributes(gregexpr("[[:digit:]]+", x)[[1]])$match.length
    pos <- c(gregexpr("[[:digit:]]+", x)[[1]])
    values <- substring(x, pos, pos + len - 1)
    pos.end <- pos + len - 1
    replacements <- sapply(values, function(x) numb2word(as.numeric(x)))      
    replacements <- switch(num.paste,
        separate = replacements,
        combine =  sapply(replacements, function(x)gsub(" ", "", x)),
        stop("Invalid num.paste argument"))
    numDF <- unique(data.frame(symbol = names(replacements), 
        text = replacements))
    rownames(numDF) <- 1:nrow(numDF)       
    pat <- paste(numDF[, "symbol"], collapse = "|")
    repeat {
        m <- regexpr(pat, x)
        if (m == -1) 
            break
        sym <- regmatches(x, m)
        regmatches(x, m) <- numDF[match(sym, numDF[, "symbol"]), 
            "text"]
    }
    return(x)
}


# MGSUB
# https://github.com/trinker/qdap/issues/201
mgsub <- function (pattern, replacement, text.var, leadspace = FALSE, 
                    trailspace = FALSE, fixed = TRUE, trim = TRUE, order.pattern = fixed, 
                    ...) {
  
  if (leadspace | trailspace) replacement <- spaste(replacement, trailing = trailspace, leading = leadspace)
  
  if (fixed && order.pattern) {
    ord <- rev(order(nchar(pattern)))
    pattern <- pattern[ord]
    
    if (length(replacement) != 1) replacement <- replacement[ord]
    
  }
  if (length(replacement) == 1) replacement <- rep(replacement, length(pattern))
  
  for (i in seq_along(pattern)){
    text.var <- gsub(pattern[i], replacement[i], text.var, fixed = fixed, ...)
  }
  
  if (trim) text.var <- gsub("\\s+", " ", gsub("^\\s+|\\s+$", "", text.var, perl=TRUE), perl=TRUE)
  text.var
}