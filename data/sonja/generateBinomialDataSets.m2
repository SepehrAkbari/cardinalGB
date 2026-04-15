-- ******************************************************************
-- GENERATE GB training DATA 
-- run this section of code once to get BOTH
-- the random binomial ideals saved as a text file,
-- and the size of each minimal GB saved in a different text file. 
-- ******************************************************************


generateGBdata = method(TypicalValue => List, Options=>{Homogeneous=>false,InfoLine=>true,ExcludeZeroBinomials=>true,MonOrder=>null,SaveFeatures=>null})
generateGBdata(ZZ,ZZ,ZZ,ZZ) := List => o -> (numVars,maxDegree,binomialsInEachSample,sampleSize) -> ( 
    if o.MonOrder===null then  S = ZZ/32003[x_0..x_(numVars-1)] else  S=ZZ/32003[x_0..x_(numVars-1),MonomialOrder=>o.MonOrder];
    filename = "RandomBinomialDataSet."|toString numVars|"vars.deg"|toString maxDegree|".sampleSize"|toString sampleSize|"."|toString binomialsInEachSample|"binomialsEach."|toString currentTime()|".txt";
    --for foolproof automation: --  filename=temporaryFileName()|".txt"; 
    --just add a "version number" at the end of the text file if one of the same name already exists. We do have a time stamp, so that should take care of most conflicts, but just in case, double-fool-proof?: [adding random # at the end])
    while  fileExists(filename)  do   filename = "RandomBinomialDataSet."|toString numVars|"vars.deg"|toString maxDegree|".sampleSize"|toString sampleSize|"."|toString currentTime()|".v"|toString random(100)|".txt";
    -- SONJA, JUNE 2021:  why are we  doing it this  way? why don't we just append to  the file, if the file already exists? "opetOutAppend" instead  of "openOut"....
    
    -- store the preset parameters for this data set on the first line of the data file: 
    parameters = "numVars = "|toString numVars|", maxDegree = "|toString maxDegree|", binomialsInEachSample = "|toString binomialsInEachSample|", sampleSize = "|toString sampleSize|", MonomialOrder = "|toString (options S).MonomialOrder;
    if o.InfoLine then (
	    f := openOut filename;
	    f << parameters << endl;
	    close f;
	    featurefile := openOut concatenate(filename,".features.txt");
	    featurefile << "Each line is a list of features, in the following order: generator degree statistics (min, max, mean, variance), number of pure power lead terms in generators, followed by any on-demand features in the order provided in the list SaveFeatures. " << endl;
	    close featurefile;
	    );

    -- generate a random binomial set, write it to file f, 
    -- then compute gb write size gb and max deg of gb, 
    -- save any custom features as well  as the input  data hardcoded features, 
    -- and  then continue to next random set.
	scan(sampleSize,i-> (
		-- generate a new random binomial set: 
		bins = randomBinomials(S,maxDegree,binomialsInEachSample,Homogeneous=>o.Homogeneous,ExcludeZeroBinomials=>o.ExcludeZeroBinomials);
		assert(#bins == binomialsInEachSample); -- just to make sure I got the correct sample size; if wrong it'll print error on dialog so easy to spot!
		-- save exponents to the open file f: 
		expos =  toString apply(sort bins,b->apply(exponents b,monexpo->monexpo));	 -- added `sort` to ensure unique rep of the data set
		-- but first get rid ouf outer {} bc they serve no purpose:
    		f := openOutAppend filename;
		f << replace(" ","",substring(1,#expos-2,expos))<<endl;
       		close f;
    	    	--		
		--BEGIN testing: 
    	    	--print "binomials:";
		--print  toString bins;
		--print "exponents:";
		--expos =  toString apply( bins,b->apply(exponents b,monexpo->monexpo));	
		--print expos;
		--print "sorted binomials:";
		--print toString sort bins;
		--print "expontents  of sorted binomials:";
		--exposSorted =  toString apply(sort  bins,b->apply(exponents b,monexpo->monexpo));	
		--print exposSorted;
		--END testing. Delete when all satisfied. see 2) in https://learningnlalg.slack.com/archives/C018FHX7UKF/p1624463495006100 
		gbf := openOutAppend concatenate(filename,".gbSizes.txt");
		gbf <<  # flatten entries gens gb ideal toList bins << endl;
		close gbf;
		--ADDING FILE FOR SAVING MAX TOTAL DEGREE OF A GB ELEMENT:  
		gbdegf := openOutAppend concatenate(filename,".gbMaxDeg.txt");
		-- the  next  line computes the maximum of the list  of degrees  of the elements of the GB:  (_1 to handle whatever M2  eles M2 outputs) 
    	    	gbdegf <<  (max (degrees  gens gb ideal toList bins)_1)_0 << endl;
		close gbdegf;		
		--end of adding. 
    	    	--
		--BEGIN testing: 
		--print  ideal toList  bins;
		--print  gens gb  ideal toList bins;
		--print  (max (degrees  gens gb ideal toList bins)_1)_0 ;
		--END testing. Delete when all satisfied. see 1) in https://learningnlalg.slack.com/archives/C018FHX7UKF/p1624463495006100 
		
	    -- FEATURES:
	    -- The ideal way (pun not intended) is if all these features are in the same file and separated by commas.
	    -- To clarify: each sample is a separate line, and the features are separated by commas. 
		-- generator degree statistics (min, max, mean, variance): 
	    	degreesOfGenerators := bins/degree; --shorthand for "apply(bins,degree)" 
	    	mean := (sum degreesOfGenerators)/#degreesOfGenerators; 
		variance :=  sum apply(degreesOfGenerators, x-> (mean_0-x_0)^2)/#degreesOfGenerators;
		-- 1) built-in hard-coded features: 
		featurefile := openOutAppend concatenate(filename,".features.txt");
		featurefile <<  (min degreesOfGenerators)_0 <<","<< (max degreesOfGenerators)_0 <<","<< toString mean_0 <<"," << toString variance; 
		    -- the various "_0" are sitting in the line above only to not write {} to the file! 
    	    	-- 2) any custom (on-demand) features from optional input: 
		if o.SaveFeatures =!= null then (
		    -- assuming SaveFeatures = {function1,function2}  and each can be applied to List:
		    features  = apply(o.SaveFeatures,fn-> fn  bins); 
		    apply(length o.SaveFeatures,k-> (
			    featurefile << ","<< features_k; 
			    )
			);
		    );
    	    	featurefile << endl; -- done with this sample; 
		close featurefile; 

-*	    
	    ---- this is replaced by the above; saving for now for purpose of documentation and comments: 
		-- START saving custom features (see 3 in https://learningnlalg.slack.com/archives/C018FHX7UKF/p1624463495006100 )
		if o.SaveFeatures =!= null then (
		    -- assuming SaveFeatures = {function1,function2}  and each can be applied to List:
		    features  = apply(o.SaveFeatures,fn-> fn  bins); 
		    --print features; -- this  has {} around the features, which are returned as a list.
		    -- now, to do: 
		    -- for each feature computed, create a file name then, add the k-th feature computed here (as features_k) to a new line of the k-th feature file: 
		    apply(length o.SaveFeatures,k-> (
			    --save k-th feature in k-th feature file:
			    featurefile := openOutAppend concatenate(filename,".feature",toString k,".txt");
			    featurefile <<  features_k << endl;
-- the "_0" is here only to not write {} to the file! 			    close featurefile;
			    )
			); -- end of saving the each of the features to their own files for this particular generating set;
		    );
		-- END saving custom features.
	    -- START saving hard-coded features; see https://learningnlalg.slack.com/archives/C01D3FK2Q6T/p1624983276006200 
	    -- 
	    -- hard-coding the following feature computations in the data generation process:
	    -- max deg of a generator in the set (we know the bound is D, but if we don't generate homogenous binomials, the actual max may be smaller?): 
	    degreesOfGenerators := bins/degree; --shorthand for "apply(bins,degree)" 
    	    maxDegf := openOutAppend concatenate(filename,".maxDegGen.txt");
	    maxDegf << (max degreesOfGenerators)_0 << endl; 
	    close maxDegf;
	    -- mean of degrees of generators: 	    
	    mean := (sum degreesOfGenerators)/#degreesOfGenerators; 
    	    meanDegf := openOutAppend concatenate(filename,".meanDegGen.txt");
	    meanDegf << (mean)_0 << endl; 
	    close meanDegf;
	    -- variance of degrees of generators: 
    	    variancef := openOutAppend concatenate(filename,".varDegGen.txt"); 
	    variancef << sum apply(degreesOfGenerators, x-> (mean_0-x_0)^2)/#degreesOfGenerators << endl; 
	    close variancef;
	    -- num of pure power leading terms in generators: 
	    mytally := bins/leadTerm/isPurePower; 
	    ppf := openOutAppend concatenate(filename,".purePowerLeadTerms.txt"); 
	    ppf << number(flatten mytally,i->i==true) << endl; 
	    close ppf;
	    -- END saving hard-coded features. 	    
*- 
	    )
	);

	    
	-- Eventually we will time out the operations and if gb doesn't complete we can save a 0 or a -1 in the gb sizes file. 

    print("Saved data to files starting with "|filename);
)

   
   end;
    -- STOP READING THE FILE.



-- ******************************************************************
-- NOTES FOR FUTURE
-- ******************************************************************
-- regarding ZERO POLYNOMIAL 
	--expos = append(expos, apply(bins,b->exponents b)); -- this makes everything with {}. We prefer [].
	-- At the moment, since we know we only have binomials: 
	expos = expos| apply(bins,b->[new Array from (exponents b)_0,new Array from (exponents b)_1]);
	-- but if we genereate a 0 then this is a problem; it assumes there is no 0 in the list! 
	-- if we want this to work for general polynomials, replace above line by the below one:
	--expos = expos| apply(bins,b->new Array from apply(exponents b,monexpo->new Array from monexpo));
-- ******************************************************************
-- TO DO, parhaps, in the future: 
--    	      	      	      	  (makes  sense if we encapsulate the "generateGBdata" method under "model")
-- [by Sonja]
-- I still want to write some code to use our Sample and Statistics part of the random package
-- because that way we can easliy get histograms of info on the data we are generating
-- rather than writing more code to get such data summaries. But it's not necessary
-- to get started, so I'll do it when I'm able. 
-- ******************************************************************
-- In particular, I am borrowing the following code for computing hard-coded sample features from RMI;
-- this code should be made to work with that code in hte next iteration? ... define "my model" etc...
statistics (Sample, Function) := HashTable => (s,f) -> (
    fData := apply(s.Data,f);
    mean := (sum fData)/s.SampleSize; -- <- should the mean be returned as RR? 
    new HashTable from {Mean=>mean,
     StdDev=>sqrt(sum apply(fData, x-> (mean-x)^2)/s.SampleSize),
     Histogram=>tally fData}
)





-- ******************************************************************
-- another way to get new filenames randomly: 
--getFilename = () -> (
--  filename := temporaryFileName();
--  while fileExists(filename) 
--    or fileExists(filename|"PHCinput") 
--    or fileExists(filename|"PHCoutput") do filename = temporaryFileName();
--  filename
--)
-- ******************************************************************
