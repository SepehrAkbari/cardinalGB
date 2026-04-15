----------
-- Generates random binomials as differences of randomly generated monomials.
----------


randomBinomials = method(TypicalValue => List, Options=>{Homogeneous=>false, ExcludeZeroBinomials=>true})
randomBinomials(PolynomialRing, ZZ, ZZ) := List => o -> (R, maxDegree, k) -> ( 
    
    -- generates monomials up to maxDegree
    mons = if o.Homogeneous then (
        flatten entries basis(maxDegree, R)
    ) else (
        flatten apply(0..maxDegree, d -> flatten entries basis(d, R))
    );
    
    mons = drop(mons, 1); -- removing 0
    
    -- generates k random binomials
    binomials = {};
    numMons = #mons;
    
    scan(k, i -> (
        indPlus = random(0, numMons - 1);
        indMinus = random(0, numMons - 1);
        
        if o.ExcludeZeroBinomials then (
            while indPlus == indMinus do (
                indMinus = random(0, numMons - 1);
            );
        );
        
        binomials = append(binomials, mons_indPlus - mons_indMinus);
    ));
    
    flatten binomials
)