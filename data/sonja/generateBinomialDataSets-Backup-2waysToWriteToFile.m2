-- ******************************************************************
-- GENERATE GB training DATA 
-- run this section of code once to get BOTH
-- the random binomial ideals saved as a text file,
-- and the size of each minimal GB saved in a different text file. 
-- ******************************************************************


generateGBdata = method(TypicalValue => List, Options=>{Homogeneous=>false,OneAtATime=>true,InfoLine=>true,ExcludeZeroBinomials=>true})--IdealsOnly=>false,
generateGBdata(ZZ,ZZ,ZZ,ZZ) := List => o -> (numVars,maxDegree,binomialsInEachSample,sampleSize) -> ( 
    S = ZZ/32003[x_0..x_(numVars-1)];
    filename = "RandomBinomialDataSet."|toString numVars|"vars.deg"|toString maxDegree|".sampleSize"|toString sampleSize|"."|toString binomialsInEachSample|"binomialsEach."|toString currentTime()|".txt";
    --for foolproof automation: --  filename=temporaryFileName()|".txt"; 
    --just add a "version number" at the end of the text file if one of the same name already exists. We do have a time stamp, so that should take care of most conflicts, but just in case, double-fool-proof?: [adding random # at the end])
    while  fileExists(filename)  do   filename = "RandomBinomialDataSet."|toString numVars|"vars.deg"|toString maxDegree|".sampleSize"|toString sampleSize|"."|toString currentTime()|".v"|toString random(100)|".txt";
    -- SONJA, JUNE 2021:  why are we  doing it this  way? why don't we just append to  the file, if the file already exists? "opetOutAppend" instead  of "openOut"....
    
    -- store the preset parameters for this data set on the first line of the data file: 
    parameters = "numVars = "|toString numVars|", maxDegree = "|toString maxDegree|", binomialsInEachSample = "|toString binomialsInEachSample|", sampleSize = "|toString sampleSize;
    if o.InfoLine then (
	    f := openOut filename;
	    f << parameters << endl;
	    close f;
	    );
    
    if not o.OneAtATime then (
	-- SONJA, JUNE 2021: i  literally see no reason why to keep this option that  first  comptues  teh  whole  list then writes to file. why don't we just always write to file one at a time?! 
    	expos = ""; 
    	ideals ={};
    	scan(sampleSize,i-> (
		-- generate a new random binomial set: 
		bins = randomBinomials(S,maxDegree,binomialsInEachSample,Homogeneous=>o.Homogeneous);
		assert(#bins == binomialsInEachSample); -- just to make sure I got the correct sample size; if wrong it'll print error on dialog so easy to spot!
		-- save exponents to the list for learning: 
		-- but first get rid ouf outer {} bc they serve no purpose:
		tempString := toString(apply(bins,b->apply(exponents b,monexpo->monexpo))); 
		expos = expos|substring(1,#tempString-2,tempString)|newline;
		-- save ideals so we can compute GB down below: 
		ideals = append(ideals,ideal toList bins);
		)
    	    );
	f = openOutAppend filename;
	f << replace(" ","", expos);
	close f;
    	gbSizes = "";
    	-- TO DO: 
    	-- for generating larger samples, include a timer and throw out an ideal we can't compute in a few minutes. 
    	-- how to best handle this? try "try" command :D see Slack!  
    	scan(ideals, I-> gbSizes = gbSizes | toString(# flatten entries gens gb I)|newline);
      	concatenate(filename,".gbSizes.txt") << gbSizes << endl << close;

    ) else ( 
    	-- generate a random binomial set, write it to file f, then compute gb write size gb, and only THEN continue to next random set.
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
		)
	    );
	-- Eventually we will time out the operations and if gb doesn't complete we can save a 0 or a -1 in the gb sizes file. 
	);
    print("Saved data to file starting with "|filename);
    )

   
   end;
    -- STOP READING THE FILE.
   --  WHAT'S BELOW NEEDS TO BE EDITED 
    -- it's the stupid option of getting a bunch of binomial sets  but NOT  computing their gb. deal with later. 

--getFilename = () -> (
--  filename := temporaryFileName();
--  while fileExists(filename) 
--    or fileExists(filename|"PHCinput") 
--    or fileExists(filename|"PHCoutput") do filename = temporaryFileName();
--  filename
--)



-- ******************************************************************
-- GENERATE binomials DATA 
-- run this section of code once 
-- to get JUST the random binomial ideals saved as a text file. 
-- See below for more! 
-- ******************************************************************
filename = concatenate("RandomBinomialDataSet.",toString numVars,"vars.deg",toString maxDegree,".sampleSize",toString sampleSize,".",toString currentTime());
parameters = concatenate("numVars = ",toString numVars,", maxDegree = ",toString maxDegree,", binomialsInEachSample = ",toString binomialsInEachSample,", sampleSize = ",toString sampleSize);
expos = []; 
S = QQ[x_0..x_(numVars-1)];
scan(sampleSize,i-> (
	bins = new Array from randomBinomials(S,maxDegree,binomialsInEachSample,Homogeneous=>homogeneous);
	assert(#bins == binomialsInEachSample); -- just to make sure I got the correct sample size; if wrong it'll print error on dialog so easy to spot!
	expos = expos| apply(bins,b->new Array from apply(exponents b,monexpo->new Array from monexpo));
	)
    )
print concatenate("writing to file ",filename);
writeData(replace(" ","",expos), parameters, filename);

-- notes for future:
	--expos = append(expos, apply(bins,b->exponents b)); -- this makes everything with {}. We prefer [].
	-- At the moment, since we know we only have binomials: 
	expos = expos| apply(bins,b->[new Array from (exponents b)_0,new Array from (exponents b)_1]);
	-- but if we genereate a 0 then this is a problem; it assumes there is no 0 in the list! 
	-- if we want this to work for general polynomials, replace above line by the below one:
	--expos = expos| apply(bins,b->new Array from apply(exponents b,monexpo->new Array from monexpo));
-- ******************************************************************
 




-- ******************************************************************


-- TO DO 
-- [by Sonja]
-- I still want to write some code to use our Sample and Statistics part of the random package
-- because that way we can easliy get histograms of info on the data we are generating
-- rather than writing mroe code to get such data summaries. But it's not necessary
-- to get started, so I'll do it when I'm able. 

