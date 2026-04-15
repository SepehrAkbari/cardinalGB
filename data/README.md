## Data

We create a dataset of random binomial ideals, compute their Gröbner bases, and extract features for model training.

### Usage

To create the dataset, configure the parameters in [`generate.M2`](./generate.m2):

- `coeffRing`: Coefficient ring for the polynomial ring (ring).
- `polyCount`: Number of polynomials in the ideal (int).
- `sampleSize`: Number of ideals to generate (int).
- `numVars`: Number of variables in the polynomial ring (int).
- `maxDegree`: Maximum degree of the polynomials (int).
- `isHmgns`: Whether to generate homogeneous polynomials (boolean).
- `excludeZeroBins`: Whether to exclude binomials that are zero (boolean).
- `monOrder`: ordering of polynomials (MonomialOrder).
- `timeLimitSeconds`: Time limit for computation in seconds (int).

Then run the script:

```bash
cd data
M2 --script generate.m2
```

### Result

The resulting dataset will be saved in the [dataset](./dataset) directory as CSV files, with a prefix based on the configuration:

- {prefix}_data: generated ideals in $p_1 t_1 v_1, \ldots p_k t_2 v_n$.
- {prefix}_features: extracted features for each ideal.
- {prefix}_gbSizes: size of the Gröbner basis for each ideal.
- {prefix}_gbMaxDeg: maximum degree of the Gröbner basis elements for each ideal.

The filename prefix is constructed as:

{poly_type}-{`sampleSize`}-d{`maxDegree`}-v{`numVars`}-b{`polyCount`}-{`coeffRing`}-{`monOrder`}.

