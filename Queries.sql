--View Doctor who have more than 1 specializations
SELECT COUNT(*) as NoOfSpecilizations,EmpID FROM DoctorSpecializations GROUP BY EmpID HAVING COUNT(*)>1;

--View Employees who have a NPINumber
SELECT * FROM Employees WHERE NPINumber != '';

--View appointment ID that did not have prescription associated with it
SELECT AppntID FROM Appointments WHERE AppntID NOT IN (SELECT a.AppntID FROM Appointments a JOIN Prescriptions p ON a.AppntID=p.AppntID);

--View all intake form details of the patients
SELECT * FROM PatientInfo p 
JOIN PatientInfo i on p.PatientId = i.PatientId 
	JOIN MedicalHistory m ON p.PatientID = m.PatientID 
		JOIN OtherMedications o ON p.PatientID = o.PatientID 
			JOIN DentalHistory d ON p.PatientID=d.PatientID;