----------
-- Executive.
----------

load "generateBinomialDataSets.m2"


-- CONFIGURATION
coeffRing = ZZ/32003
polyCount = 5
sampleSize = 1
numVars = 3
maxDegree = 4
isHmgns = false
excludeZeroBins = true
monOrder = Lex
timeLimitSeconds = 60

-- EXECUTION
resultPrefix = generateGBdata(
    numVars, 
    maxDegree, 
    polyCount, 
    sampleSize, 
    Homogeneous => isHmgns,
    ExcludeZeroBinomials => excludeZeroBins,
    MonOrder => monOrder,
    TimeLimit => timeLimitSeconds,
    CoeffRing => coeffRing
)