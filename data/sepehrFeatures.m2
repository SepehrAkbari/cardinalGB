----------
-- Extracts other features.
----------


extractSepehrFeats = method(TypicalValue => List)
extractSepehrFeats(Ideal) := (I) -> (
    d := dim I; -- dimension
    mg := numcols mingens I; -- num of minimal generators
    
    deg := -1; -- degree of ideal
    reg := -1; -- regularity of ideal

    -- ideal must be homogeneous to get deg/reg
    if isHomogeneous I then (
        deg = degree I;
        try (reg = regularity I) else (reg = -1);
    );
    
    return {
        ("dim", d),
        ("mingens", mg),
        ("degree", deg),
        ("regularity", reg)
    };
)