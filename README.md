On Comparing Heterogeneity Across Biomarkers
============================================

Overview
--------
This is a description of the MATLAB code and data accompanying the paper "On Comparing Heterogeneity Across Biomarkers" by Steininger et al, to be
published in Cytometry A.

The primary contribution of this work is a method to determine the extent to which (possibly non-co-stained) biomarkers re-identify the same cellular subpopulations.
Crucially, this method does not require biomarkers of interest to be co-stained on the same cells. It is enough if the biomarkers are stained (possible separately) 
on common set of cell lines, where subpopulations are identified independently for each marker. 

The degree of subpopulation re-identification between markers is quantified by using the so called Subpopulation Structure Similarity(S3) score. 

Correspondingly,the primary novelty of the MATLAB code supplied here is the calculation of the S3 score between a pair of biomarkers taking as input the 
subpopulation profiles (fractions of cells in different sub-populations) of the biomarkers across a common set of cell lines. This code can be found 
in the `Core_Functions` directory. More specifically, if the subpopulation profiles for a set of biomarkers are stored in `profiles.mat` in a format described 
in the data section below, then executing:
```
Calculate_S3_Scores('profiles.mat','S3_output.mat');
```
will calculate the S3 scores between all pairs of biomarkers and store the result in `S3_output.mat` in a format described in the Data section below.

The following code is additionally provided to reproduce the figures given in the main text. All code below was tested using Matlab v.2014a.

Figures:
-------

The .m files in the root level directory are scripts that will generate the figures in the paper. It should be noted that while there should be strong qualitative
agreement between the figures generated using this code and those published in the paper, there may be minor quantitative difference. These differences are on account 
of the randomness inherent to the process of generating subpopulation profiles (most results shown are found by averaging results across multiple runs).

### Figure 1: Cartoon Overview 
This is a cartoon overview of our approach which is not generated from code. 

### Figure 2: Simple demonstration using 2 subpopulations
2 pairs of **non-co-stained** biomarkers were stained on a common set of cell lines. For each biomarker cells were classified into low and high expressing subpopulations.
In the plots, each point corresponds to a single cell line and it's x and y coordinates are given by the fraction of cells in low (or high as specified) subpopulations. The
relations between the subpopulation fractions tell us about the relationship between the subpopulations of the different markers. To generate this figure execute
```
Fig2.m
```

### Figure 3: Validation
The extent to which subpopulation state based on one biomarker predict those of another is determined by co-staining the biomarkers, and quantified using
the mutual information between the biomarkers' subpopulation assignments. The S3 score, which does not require co-staining, is then compared to this
gold standard of mutual information for multiple biomarker pairs. The figure consists of two parts
1. Validation scatter plot of S3 vs Mutual Information. This can be run using `Fig3_scatterplots.m`
2. Cloud plots to help interpret the results above. Shown are the distribution of biomarker phenotypes across a selection of cell lines. Run using `Fig3_scatterplots.m`


### Figure 4:
This is the results figure, showing a similarity matrix between different biomarkers based on their S3 score.To generate this run `Fig4.m`


Data:
-----
The data used in this experiment comes from two different sets of experiments
1. LCC: a panel of 33 lung cancer cell lines stained for various biomarkers. This is referred to as **`cancer_cell_lines`** in the data.
2. CP: A panel of 49 clones of a single lung cancer cell line (H460) stained for various biomarkers. This is referred to as **`clone`** in the data.


Data to generate various figures is present in the `Data` directory. There are three different kinds of data stored
1. **Features**: Raw features for each cell in the data set across all biomarkers:`features.mat`
2. **Profiles**: Subpopulation profiles for the different cell lines in the data set:`profiles.mat` (with biomarker specific number of subpopulations) 
and `2subpop_profiles.mat` (for profiles with only 2 subpopulations for all marker as need for Figure 2)
3. **S3**: S3 scores between the different pairs of biomarkers:`S3.mat` and `S3_paper.mat`. 

Note: `S3.mat` was generated using the profiles and code provided here. `S3_paper.mat` contains the results shown in the paper, 
and calculated on a computing cluster using a larger number of randomizations and synthetic repeats. The mean levels are similar for both files, 
but `S3_paper.mat` shows a smaller error bars on account of increased sampling.

Each file contains the corresponding data for both data sets. The descriptions of the different data formats are below.


### Features
To load the features use:
```
>> feature_data=load('features.mat')

feature_data = 

       data_set_names: {'clone'  'cancer_cell_lines'}
    data_set_features: {2x1 cell}
```
The features themselves are stored within the variable `data_set_features`, each element of which contains the features for a single data set. The variable `data_set_names` tells
us that the first element of `data_set_features` contains the data for the `clone` data set, while the second element contains the data for the `cancer_cell_lines`.

Thus to view the data for the `cancer_cell_lines` data one would use:
```
>> feature_data.data_set_features{2}

ans = 

          marker_names: {11x1 cell}
    marker_set_numbers: [11x1 double]
         feature_names: {11x1 cell}
          feature_data: {11x1 cell}
```
The variables are organized on a per biomarker basis (11 biomarkers were studied in this data set). They are described in greater detail below:

####1. `marker_names`
is a cell array containing the names of the various biomarkers
```
>> feature_data.data_set_features{2}.marker_names

ans = 

    'DNA'
    'betacatenin'
    'vimentin'
    'DNA'
    'pSTAT3'
    'pPTEN'
    'DNA'
    'H3K9Ac'
    'pAkt'
    'DNA'
    'E-Cadherin'
```
####2. `feature_names`:
The single cell features used are marker specific, and this information is contained in the cell array `feature_names`
```
>> feature_data.data_set_features{2}.feature_names     

ans = 

    'Average DNA Nuclear Intensity'
    'Average Cytoplasmic Intensity'
    'Average Cellular Intensity'
    'Average DNA Nuclear Intensity'
    'Average Cellular Intensity'
    'Average Cellular Intensity'
    'Average DNA Nuclear Intensity'
    'Average Nuclear Intensity'
    'Average Cellular Intensity'
    'Average DNA Nuclear Intensity'
    'Average Cytoplasmic Intensity'
```

Thus, for the second biomarker (betacatenin), each cell is characterized by the average intensity of that biomarker in the cytoplasmic pixels of that cell.

####3. `marker_set_numbers`:
Since it is only possible co-stain a few markers on a cell, the biomarkers were split into different marker-sets. All biomarkers within the same marker-set were co-stained, and thus the levels of these biomarkers is measured simultaneously on the same cells. For biomarkers in different marker-sets, no cell is stained 
for both biomarkers. `marker_set_numbers` is an array specifying which marker set each biomarker belongs to.
```
>> feature_data.data_set_features{2}.marker_set_numbers

ans =

     1
     1
     1
     2
     2
     2
     3
     3
     3
     4
     4
```
Thus the first three biomarkers (dna,betacetenin and vimentin were costained), but the second and eleventh biomarkers (betacatenin and e-cadherin) were not.


####4. `feature_data`:
This contains the values of single cell features organized by cell-line
```
>> feature_data.data_set_features{2}.feature_data 

ans = 

    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
    {33x1 cell}
```
Each element of `feature_data` corresponds to the collection of single cell features for a single biomarker. Within each element we have a further
grouping by cell lines. Since the `cancer_cell_lines` dataset contains 33 cell lines there are 33 elements. Thus
```
>> feature_data.data_set_features{2}.feature_data{5}{6}

1.0e+03 *

    0.5052
    0.6340
    0.5338
    0.6901
    0.8600
    0.6267
     ....
     ....
```
gives us a column vector of the values of features for the 6th cell line of the 5th biomarker (pSTAT3). Each row is the value of the feature for a
single cell belonging to the specified cell line.

### Profiles:
To load profile data run
```
>> profile_data=load('profiles.mat')

profile_data = 

       data_set_names: {'clone'  'cancer_cell_lines'}
    data_set_profiles: {2x1 cell}

```
`data_set_names` and `data_set_profiles` are similar to the corresponding elements in features except that `data_set_profiles` contains subpopulation profiles
(rather than feature data).

The profile data for the `cancer_cell_lines` data set can be accessed as:
```
>> profile_data.data_set_profiles{2}

ans = 

          marker_names: {11x1 cell}
    marker_set_numbers: [11x1 double]
         feature_names: {11x1 cell}
         subpop_models: {11x10 cell}
              profiles: {11x10 cell}
    subpop_assignments: {11x10 cell}
```
The organization of this data is by biomarker (this dataset contains 11 biomarkers), just as for the feature data. The fields `marker_names`,
`marker_set_numbers` and `feature_names` are identical to those used for the feature data. Thus the new fields are


####1. `subpop_models`:
To assign cells to subpopulations, the single cell features corresponding to each biomarker are fit to a gaussian mixture model. `subpop_models` contains these models.
Since the models are the result of a non-convex optimization process, there is a stochastic element to them. To obtain more robust results, we
therefore generate 10 different "synthetic replicate" models for each biomarker (these models should, in principle, be the same, differing only in the stochasticity resulting
from the optimization process).
```
>> profile_data.data_set_profiles{2}.subpop_models

ans = 

  Columns 1 through 7

    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]

  Columns 8 through 10

    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
    [1x1 gmdistribution]    [1x1 gmdistribution]    [1x1 gmdistribution]
```
Each row of this matrix corresponds to a single biomarker, and each column is a different replicate model. Thus the 4th replicate for the 5th
biomarker is given by
```
>> profile_data.data_set_profiles{2}.subpop_models{5,4}

ans = 

Gaussian mixture distribution with 6 components in 1 dimensions
Component 1:
Mixing proportion: 0.064124
Mean:   4.2449e+03

Component 2:
Mixing proportion: 0.143616
Mean:   2.0677e+03

Component 3:
Mixing proportion: 0.279754
Mean:   1.0890e+03

Component 4:
Mixing proportion: 0.310095
Mean:  660.9377

Component 5:
Mixing proportion: 0.005104
Mean:   1.1466e+04

Component 6:
Mixing proportion: 0.197307
Mean:  396.1769
```
Each model is a standard MATLAB gmdistribution. It should be noted that the number of components, i.e. number of subpopulations, is determined on a per biomarker basis using the BIC
score. However, this data is not included here.

####2. `subpop_assignments`:
Based on the models above and their single cell feature values, cells are assigned to biomarker specific gmm subpopulations. `subpop_assignments` contains the
subpopulation that each cell is assigned to, grouped by cell line.
```
>> profile_data.data_set_profiles{2}.subpop_assignments

ans = 

    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}    {33x1 cell}
```
The top-level organization is similar to the models, with each row corresponding to a biomarker and each column to a "synthetic replicate". Each
element is a cell with sub-elements corresponding to different cell lines (there are 33 cell lines for this data set). Thus to access the
subpopulation assignments for 4th replicate model of the 5th marker we would use:
```
>> profile_data.data_set_profiles{2}.subpop_assignments{5,4}

ans = 

    [ 9309x1 double]
    [ 3579x1 double]
    [  734x1 double]
    [ 2869x1 double]
    [ 1344x1 double]
    [ 1051x1 double]
    [  669x1 double]
    [ 1419x1 double]
    [ 1116x1 double]
    [ 1247x1 double]
    [ 3496x1 double]
    [ 2739x1 double]
    [ 1250x1 double]
    [ 1353x1 double]
    [ 1413x1 double]
    [ 2554x1 double]
    [  729x1 double]
    [ 1859x1 double]
    [ 2344x1 double]
    [ 1364x1 double]
    [ 1219x1 double]
    [ 2024x1 double]
    [11001x1 double]
    [ 1877x1 double]
    [ 1368x1 double]
    [ 1466x1 double]
    [  737x1 double]
    [ 1303x1 double]
    [ 1835x1 double]
    [  608x1 double]
    [ 1959x1 double]
    [  349x1 double]
    [  614x1 double]
```
Each element here corresponds to one (of the 33) cell lines. For example the second element, corresponds to the 2nd cell line, and has 3579 values
corresponding to the different cells (biological not MATLAB) within that cell line. Each of these 3579 values lies between 1 and the number of
subpopulation used for the corresponding biomarker.

####3. `subpop_profiles`:
   The subpopulation assignments across cell lines can be represented in terms of a subpopulation profile (as descried earlier), with each cell line 
   represented by its own profile for a specific biomarker (and synthetic replicate). The subpopulation profile for a cell line contains the fraction
   of its cells assigned to each subpopulation. Thus, each profile is a vector of length equal to the number of components (subpopulations) used in 
   the corresponding model. 
```
>> profile_data.data_set_profiles{2}.profiles               

ans = 

    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]
    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]
    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]
    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]
    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]
    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]
    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]
    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]
    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]    [33x5 double]
    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]    [33x4 double]
    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]    [33x6 double]
```
As above, each row correspond to a biomarker and each column to a synthetic replicate. Each element of this cell array is a matrix with rows
correponsind to cell lines (there are 33 cell lines in this dataset) and columns to subpopulations. Since that the number of subpopulations is biomarker
specific, all replicates for a biomarker use the same number of subpopulations.

###S3

To load the S3 results 
```
>> s3_data=load('S3.mat')

s3_data = 

    data_set_names: {2x1 cell}
       data_set_S3: {2x1 cell}

>> s3_data.data_set_names
```
The top level organization follows the same format as features and profiles. To access the S3 data for the second data set we would use
```
>> s3_data.data_set_S3{2}

ans = 

        s3_matrix: [11x11 double]
     marker_names: {11x1 cell}
    s3_matrix_std: [11x11 double]
```
Results are organized by biomarker (there are 11 biomarkers for this dataset), as for profiles and features. `marker_names` is the same as for features and profiles.
####1. `s3_matrix`:
Contains the S3 score between all possible pairs of biomarkers. Thus the S3 score between the 3rd and 4th biomarkers can be found as
```
>> s3_data.data_set_S3{2}.s3_matrix(3,4)

ans =

    0.0254
```

####2. `s3_matrix_std`:
   This matrix captures the uncertainty in the S3 measurements arising from the stochasticity in optimizations. This is estimated
   based on the standard deviation in the S3 scores across all possible pairs of synthetic replicates for the two biomarkers being considered. The
   indexing is the same as for `s3_matrix`

