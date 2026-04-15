----------
-- Handles Gröbner basis computations with timeouts.
----------


computeGBWithTimeout = method(TypicalValue => List)
computeGBWithTimeout(Ideal, ZZ) := (I, timeLimit) -> (
    G := null;
    timeoutOccurred := false;
    
    try (
        alarm timeLimit; 
        G = gens gb I; 
        alarm 0; 
    ) else (
        alarm 0; 
        timeoutOccurred = true;
    );
    
    if timeoutOccurred then return null else return G;
)