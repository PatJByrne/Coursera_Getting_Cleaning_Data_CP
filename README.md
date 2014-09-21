Coursera_Getting_Cleaning_Data_CP
=================================

  
Code runs as such: - Data is read into the tree.  Subject is converted to 2-digit, zero padded so that it can be properly sorted.
The y data (aka the activity) is replaced with its English Name using activity
labels.txt.  
The data in X_test and X_train are stepped through element by element, and a matrix is created to contain the tidied data.  X is tidied by selecting a row in the tidy matrix based on the columns and rows in the un tidy data.
The data is then averaged by selecting every measurement(across time and frequency, and various measurements, but whatever.  Sensible information isn't really the point of the excersize I guess, and placed in )
Runs slow, but it works, I guess.