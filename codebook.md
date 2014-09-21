CODEBOOK
=======

tidy_data.txt:
-------	
	* Subject - anonymized data.  Each number refers to a different person performing the tests
	* Activity - English language description of the type of activity performed by the subject when the measurements were taken
	* Domain - time specifies that th measurements were taken in the time domain, f for freqency
	* Direction - X/Y/Z refer to the direction in which the measurement was taken.  NA if the measurement was of the absolute magnitude of the measurement
	* Meas_Object - 'Body' for measurements of the subject him/herself or 'Gravity' if the measurement is a low frequency measurement of gravitational acceleration
	* Meas - Acc - acceleration, AccJerk - the time rate of change of the accelration, Gyro - the angular velocity from the gyroscope, GyroJerk - the time rate of change of the angular velocity, AccMag - the magnitude of the acceleration, AccJerkMag - magnitude of the AccJerk, GyroMag - the magnitude of the angular veocity, GyroJerkMag - magnitude of the GyroJerk
	* Analysis_type - Mean - the average of the data gathered, Std Dev - the standard deviation
	* Meas_Value - the actual value as calculated in the dataset.


tidy_means:
------
	* Subject - anonymized data.  Each number refers to a different person \performing the tests
	* Activity - English language description of the type of activity perfo\rmed by the subject when the measurements were taken
     	* Mean_mean - the average of all the mean measurements in tidy_data.txt
	* Mean_Std - the average of all the standard deviations in tidy_data.txt