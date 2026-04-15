----------
-- Orchestrates data generation, computation, and feature extraction.
----------

load "randomBinomialIdeals.m2"
load "computeGB.m2"
load "binomialFeatures.m2"


generateGBdata = method(TypicalValue => String, Options=>{
    CoeffRing => ZZ/32003,
    Homogeneous => false, 
    ExcludeZeroBinomials => true, 
    MonOrder => null, 
    SaveFeatures => null,
    TimeLimit => 60 
})

generateGBdata(ZZ, ZZ, ZZ, ZZ) := String => o -> (numVars, maxDegree, binomialsInEachSample, sampleSize) -> ( 

    K := o.CoeffRing;
    
    -- ring
    S := if o.MonOrder === null 
        then K[x_0..x_(numVars-1)] 
        else K[x_0..x_(numVars-1), MonomialOrder=>o.MonOrder];
        
    -- monomial order
    orderName := if o.MonOrder === null then "GRevLex" else toString o.MonOrder;

    -- 
    charName := if char K == 0 then "QQ" else "ZZ" | toString(char K);
    ringName := if char K == 0 then "QQ" else "ZZ" | toString(char K);

    -- file naming
    baseFilename := "binom-" | toString sampleSize | "-d" | toString maxDegree | "-v" | toString numVars | "-b" | toString binomialsInEachSample | "-" | ringName | "-" | orderName;
    
    try makeDirectory "dataset";
    outDir := "dataset/" | baseFilename | "/";
    try makeDirectory ("dataset/" | baseFilename);
    
    filenameData := outDir | baseFilename | "_data.txt";
    filenameGBSizes := outDir | baseFilename | "_gbSizes.txt";
    filenameGBMaxDeg := outDir | baseFilename | "_gbMaxDeg.txt";
    filenameFeatures := outDir | baseFilename | "_features.txt";

    print("Generating. Data will be saved in: " | outDir);

    -- headers
    headerList := {};
    scan(1..binomialsInEachSample, p -> (
        scan(1..2, t -> (
            scan(1..numVars, v -> (
                headerList = append(headerList, "p" | toString p | "t" | toString t | "v" | toString v);
            ));
        ));
    ));
        -- data header
    dataHeader := demark(",", headerList);
    fDataInit := openOut filenameData;
    fDataInit << dataHeader << endl;
    close fDataInit;
        -- gbSizes header
    fSizeInit := openOut filenameGBSizes;
    fSizeInit << "gbSize" << endl;
    close fSizeInit;
        -- gbMaxDeg header
    fDegInit := openOut filenameGBMaxDeg;
    fDegInit << "gbMaxDeg" << endl;
    close fDegInit;
    
    scan(sampleSize, i -> (
        
        -- generation
        bins := randomBinomials(S, maxDegree, binomialsInEachSample, Homogeneous=>o.Homogeneous, ExcludeZeroBinomials=>o.ExcludeZeroBinomials);
        
        sortedBins := sort bins;
        
        flatExpos := flatten apply(sortedBins, b -> flatten exponents b);
        exposCSV := demark(",", apply(flatExpos, toString));
        
        fData := openOutAppend filenameData;
        fData << exposCSV << endl;
        close fData;
        
        -- computation
        I := ideal toList bins;
        G := computeGBWithTimeout(I, o.TimeLimit);
        
        fSize := openOutAppend filenameGBSizes;
        fDeg  := openOutAppend filenameGBMaxDeg;
        
        if G === null then (
            fSize << "-1" << endl;
            fDeg  << "-1" << endl;
        ) else (
            fSize << # flatten entries G << endl;
            fDeg  << (max(degrees G)_1)_0 << endl;
        );
        close fSize; close fDeg;
        
        -- feature extraction
        featurePairs := extractBaseFeatures(bins);
        
        -- reading features
        if o.SaveFeatures =!= null then (
            scan(o.SaveFeatures, customFeat -> (
                featName := customFeat_0;
                featFunc := customFeat_1;
                featurePairs = append(featurePairs, (featName, featFunc bins));
            ));
        );
        
        -- header
        if i == 0 then (
            fFeatInit := openOut filenameFeatures;
            headerLine := demark(",", apply(featurePairs, p -> p_0));
            fFeatInit << headerLine << endl;
            close fFeatInit;
        );
        
        -- writing
        fFeat := openOutAppend filenameFeatures;
        dataLine := demark(",", apply(featurePairs, p -> toString(p_1)));
        fFeat << dataLine << endl;
        close fFeat;
    ));
    
    return baseFilename;
)