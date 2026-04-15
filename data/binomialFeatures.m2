----------
-- Extracts features from a list of binomials.
----------

load "sepehrFeatures.m2"


extractBaseFeatures = method(TypicalValue => List)
extractBaseFeatures(List) := (bins) -> (
    -- base statistical features
    degreesOfGenerators := bins/degree;
    minD := (min degreesOfGenerators)_0; -- minimum degree among generators
    maxD := (max degreesOfGenerators)_0; -- maximum degree among generators
    meanD := (sum degreesOfGenerators) / #degreesOfGenerators; -- mean degree of generators
    varD := (sum apply(degreesOfGenerators, x -> (meanD_0 - x_0)^2)) / #degreesOfGenerators; -- variance of degrees of generators
    purePowers := number(bins, b -> # (support leadTerm b) == 1); -- pure powers generators count
    
    baseFeats := {
        ("minDeg", minD),
        ("maxDeg", maxD),
        ("meanDeg", meanD_0),
        ("varDeg", varD),
        ("purePowerLeadTerms", purePowers)
    };
    
    -- sepehr's features
    I := ideal toList bins; 
    sepehrFeats := extractSepehrFeats(I);

    -- combine
    return join(baseFeats, sepehrFeats);
)