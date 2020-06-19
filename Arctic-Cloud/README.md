A Guide to the Project
======================

The technical details on clouds and statstical support is based on Prof. Bin Yu's 2008 paper, found here: https://www.jstor.org/stable/pdf/27640081.pdf?casa_token=hRh3Cem5CokAAAAA:qqqY6NdBLtC_UKTKeOuKs_fRRqwrfODATjfnuEdZ4uZ8xSn5YcCGMu8MUVO1btgg7ZPIQ6e7kUsWSDSHBHwRlaTOQzCi7QDsZPbrmGUVVuKUoghudPYN

The goal of this project is the exploration and modeling of cloud detection in the polar regions based on radiance recorded automatically by the MISR sensor abroad the NASA satellite Terra. We built classification models to distinguish the presence of cloud from the absence of clouds in the images using the available signals/features.

*The following document serves as an aid to the accompanying code and
report on the cloud classification problem.*

Data Collection and Exploration
-------------------------------

Images were loaded as dataframes. Initially, data was summarized by
plotting points (geom\_point) at each x,y coordinate, color coding them
based on expert\_label values. Slight resizing was implemented when
extracting plots to improve readability and aesthetic. Ggplot was used
to generate maps.

EDA was carried out, chiefly by plotting pairwise scatterplots using R’s
convenient pairs() function. The relationship between expert labels and
individual features were of particular importance, and were created
using geom\_point() function in ggplot2. These plots provided early
indications of which features would become the focus of the consequent
analysis. Some features clearly showed greater separation of the labels.

Preparation
-----------

Before the data was split, it was necessary to get rid of the ‘0’ or
‘unknown’ labels. They are of not useful when training models, although
did serve a purpose in the EDA stage.  
**Main Splitting Method:** The main splitting method involved cutting up
each image into equally sized grids. A proportion of these grids would
be sent to the train, validation and test sets. \* ‘grid\_split’ : the
function that implemented this splitting method. Data must be prepared
so each point falls into an x-category and y-category. This was done
using ‘cut’ at certain intervals along x and y axes. Within the
function, image data is grouped by x and y categories (which is
equivalent to assigning grids to the image). Then a random portion of
these grids are sent to train, val and test sets. The methodology
involved running this function for each image. Then combining the 3
train, val and test sets at the end. Secondary Splitting Method

**Secondary Split Method** The secondary splitting method,
inconveniently appearing in the code as the first splitting method
(method 1), involves a deeper infiltration of the pixel data. As before,
data is split into grids using the “cut” function, but now within each
grid, we assign a proportion of the data to train, validation and test
respectively. (Whereas before a whole grid was assigned as being train,
validation or test) \* ‘split\_image’: Split image is a function whose
main feature is a for loop. The function loops over each grid, and
within each grid collecting data for the train, validation and test
sets. As before, the methodology involved running this function for each
image, then combining corresponding sets: train, validation and test
sets.

**Accuracy of a trivial classifier:** Straight-forward implementation.
Accuracy was calculated by counting the number of correct
identifications (1 - loss). As “==” is boolean, taking the mean will
give us the accuracy.

**Best Features** First histograms of the data were created using
ggplot, and colour separation based on class, to see if there were any
features that naturally separated the classes. Heatmap, from “corrplot”
library is run on all 8 features to identify correlations between them.
Redundant features were removed based on this information, using the
findCorrelation function from caret. To improve robustness, we trained a
simple logistic classifier on single features. Those with high accuracy
were identified as best suited. Data was first filtered to remove
useless 0 values. Train function and predict functions from caret
package were used.

**CVGeneric** CV Generic is a function that cross validates different
classification methods based on our best split method. The split method
we chose was the “randomly assigning grids” method. CV Generic splits
data into k-folds based on grids (k groups of grids). Then runs the
typical cross validation method: assign a grid for validation, train on
the k-1 grids, get error. The function can theoretically handle training
for any model in the caret package. Logistic and adaboost are
implemented in the function separately to improve speed. Inputs:
classifier, features, labels, k, loss function Outputs: List(Overall
loss, loss in each fold)

Modelling
---------

*Methods Tried: SVM, Logistic, QDA, LDA, ADABoost (tree stumps)* Test
error was reported by predicting on the test set created using our main
data splitting method. Predict() function was used, and the mean()
method descibed above used to get classification accuracy CVGeneric was
used to report cross fold cv error, and average k-fold error *There is
code for probit, although this didn’t make it into the final report*

**ROC Curves** Library pROC was used to generate ROC curves. Cutoff
points were determined by the coords() function in pROC, which returns
the threshold value for a “best” fit of our choice. We chose Youden’s
index to determine cutoff. Side by side plots of basic models: logistic,
qda and lda. ROC Plots of Adaboost with varying hyperparameter: number
of trees (tree stumps were used) ROC Plot of SVM with cost = 0.25.

Diagnostics
-----------

Good classification model was ADABoost: chosen for its speed (compared
to SVM) and accuracy In the first section we attempt to determine which
hyperparameter values to use. First we determine number of trees,
predicting on validation and test sets using a range of tree values.
Vectors of Validation Loss and Test Loss are passed to ggplot, where we
visually identify best parameter value based on minimizing test loss.
After determining number of trees, we repeat same methodology for tree
depth.

**Decision Boundary Plot:** Required libraries: grid, gridExtra Grid is
created using Grid function for sequences of NDAI, CORR and SD (our main
feature values). *PlotGrid function:* Plot Grid function creates a side
by side plot of the decision region, and the plotted points on two
feature axes. *Inputs: prediction values, grid, PredictorA: Feature 1,
PredictorB: Feature 2 *Outputs: ggplot of decision region and
scatterplot of data.

**Patterns in Misclassification Errors:** Required library: hexbin We
use our best predictor to predict image1, image 2 and image 3. Hexbin
creates a 2d histogram counting the number of misclassification errors
in each small hexagonal region on the x-y scale. Pass points where a
mismatch between expert\_label and predicted label occurred to this
function.

**Range of Feature Values Problem** Plot histograms of misclassification
errors, seeing how they are distributed along each features scale. Basic
ggplot method, with color separation based on expert label.

**A Better Classifier** Three Approaches were tried 1. PCA was used to
extract 3 best features. These 3 features were used to train adaboost,
with the parameters identified as being strongest from earlier section.
Screeplots were generated using plot() function. Autplot() displayed the
original feature vectors on the axes of the stronges principal
components. Test error and train error was calculated by predicting on
transformed features of the test set and train set respectively. 2.
Gradient Boosting seemed an improvement on Adaboost. Gradient Boosting
was run using caret package, and with input of all 8 features. Test and
train error was calculated using the typical methods. The summary()
function returns a histogram of feature importance in the gradient boost
model. Plot() of the gradient boost model shows evolution of train and
test accuracy as parameters are tuned. ROC Curve was generated using the
same methods as before. 3. Neural Networks. Requires keras package.
Keras\_model\_sequential initalises the network architecture, within
which we used a series of logistic layers as this is a classification
problem. Dropout layers were added to assist with overfitting, and data
was normalized at each step. Loss was defined as “binary cross entropy”
with optimizer, “Adam”. Model was fitted to the test data, and plot()
generated a display of train/test error.

**A second way of splitting** Methodology in 4a) and 4b) was repeated in
this part. Except this time applied to train data/test data split using
the secondary method.
