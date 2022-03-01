/*  InstallToothHeavenDentistry.SQL - Creates the DENTAL CLINIC database	*/ 
/*	Group 11 Data Management and Database Design Fall 2021 	*/
/*	All Rights Reserved.	*/

USE master

raiserror('BEGINNING InstallToothHeavenDentistry.SQL...',1,1) with nowait
GO

if exists (select * from sysdatabases where name='toothheavendentistry')
begin
  raiserror('DROPPING EXISTING toothheavendentistry DATABSE...',0,1)
  DROP database toothheavendentistry
end
GO

CHECKPOINT
GO

raiserror('CREATING toothheavendentistry DATABASE...',0,1)
GO

CREATE DATABASE toothheavendentistry
GO

USE toothheavendentistry
GO

if db_name() <> 'toothheavendentistry'
   raiserror('ERROR IN InstallToothHeavenDentistry.SQL, ''USE toothheavendentistry'' FAILED!!  KILLING THE SPID NOW.',22,127) with log
GO

raiserror('STARTING TABLE CREATION...',0,1)
GO

/*	CREATE Appointment Schedule TABLE - ToothHeavenDentistry	*/
CREATE TABLE AppointmentSchedule(
	SchedID INT IDENTITY(1,1) NOT NULL UNIQUE,
	Date DATE NOT NULL,
	StartTime TIME NOT NULL,
	EndTime TIME,
	isCancelled INT DEFAULT 0 NOT NULL,
	PRIMARY KEY (SchedID),
	CONSTRAINT AppointmentEndTime CHECK (EndTime>StartTime)
);

/*	CREATE Appointment Type TABLE - ToothHeavenDentistry	*/
CREATE TABLE AppointmentType(
	AppntTypeID INT IDENTITY(1,1) NOT NULL UNIQUE,
	TypeName VARCHAR(30) NOT NULL CHECK (TypeName IN ('Hygienic', 'Emergency', 'Consultation', 'Regular check-up', 'Surgery')),
	PRIMARY KEY (AppntTypeID),
);

/*	CREATE Drug Records TABLE - ToothHeavenDentistry	*/
CREATE TABLE DrugRecords(
	DrugID INT IDENTITY(1,1) NOT NULL UNIQUE,
	DrugName VARCHAR(30) NOT NULL,
	Description VARCHAR(70) NOT NULL,
	Usage VARCHAR(255) NOT NULL,
	Price MONEY NOT NULL,
	PRIMARY KEY (DrugID)
);

/*	CREATE Employee Types TABLE - ToothHeavenDentistry	*/
CREATE TABLE EmployeeTypes(
	TypeId INT IDENTITY(1,1) NOT NULL UNIQUE,
	JobTitle VARCHAR(30) CHECK (JobTitle IN ('Dentist', 'Hygienist')),
	PRIMARY KEY (TypeID),
);

/*	CREATE Address Records TABLE - ToothHeavenDentistry	*/
CREATE TABLE AddressRecords(
	AddressID INT IDENTITY(1000,1) NOT NULL UNIQUE,
	Street VARCHAR(100) NOT NULL,
	City VARCHAR(20) NOT NULL,
	State CHAR(2) NOT NULL,
	Zip CHAR(5) NOT NULL CHECK (Zip like '[0-9][0-9][0-9][0-9][0-9]'),
	PRIMARY KEY (AddressID)
);

/*	CREATE Employees TABLE - ToothHeavenDentistry	*/
CREATE TABLE Employees(
	EmpID INT IDENTITY(20210000,1) NOT NULL UNIQUE,
	TypeID INT REFERENCES EmployeeTypes(TypeId),
	FName VARCHAR(30) NOT NULL,
	LName VARCHAR(30) NOT NULL,
	AddressID INT REFERENCES AddressRecords(AddressID),
	PhoneNo VARCHAR(14) NOT NULL,
	MailID VARCHAR(50),
	DOB DATE NOT NULL,
	Gender CHAR(7),
	NPINumber CHAR(10),
	PRIMARY KEY (EmpID)
);

/*	CREATE Doctor Specializations TABLE - ToothHeavenDentistry	*/
CREATE TABLE DoctorSpecializations(
	SpecializationID INT IDENTITY(1,1) NOT NULL UNIQUE,
	EmpID INT REFERENCES Employees(EmpID),
	SpecializationName VARCHAR(40),
	PRIMARY KEY (SpecializationID)
);

/*	CREATE Clinic Location TABLE - ToothHeavenDentistry	*/
CREATE TABLE ClinicLocation(
	ClinicID INT IDENTITY(1,1) NOT NULL UNIQUE,
	PhoneNo VARCHAR(14) NOT NULL,
	AddressID INT REFERENCES AddressRecords(AddressID),
	Name VARCHAR(100) NOT NULL,
	NoOfFloors INT NOT NULL,
	NoOfRooms INT NOT NULL,
	PRIMARY KEY (ClinicID)
);

/*	CREATE Rooms TABLE - ToothHeavenDentistry	*/
CREATE TABLE Rooms(
	RoomID INT IDENTITY(1,1) NOT NULL UNIQUE,
	ClinicID INT REFERENCES ClinicLocation(ClinicID),
	RoomType VARCHAR(20) NOT NULL CHECK (RoomType IN ('Hygienist', 'General', 'Endodontic', 'Emergency', 'Orthodontic')),
	RoomFloor INT NOT NULL,
	PRIMARY KEY (RoomID)
);

/*	CREATE Equipments TABLE - ToothHeavenDentistry	*/
CREATE TABLE Equipments(
	EquipID INT IDENTITY(1,1) NOT NULL UNIQUE,
	RoomID INT REFERENCES Rooms(RoomID),
	EquipName VARCHAR(30) NOT NULL,
	PRIMARY KEY (EquipID)
);

/*	CREATE Pharmacy TABLE - ToothHeavenDentistry	*/
CREATE TABLE Pharmacy(
	PharmacyID INT IDENTITY(1,1) NOT NULL UNIQUE,
	DrugID INT REFERENCES DrugRecords(DrugID),
	ClinicID INT REFERENCES ClinicLocation(ClinicID),
	Qty INT NOT NULL
	PRIMARY KEY (PharmacyID, DrugID)
);

/*	CREATE Patient Info TABLE - ToothHeavenDentistry	*/
CREATE TABLE PatientInfo(
	PatientID INT IDENTITY(12000,1) NOT NULL UNIQUE,
	FName VARCHAR(30) NOT NULL,
	LName VARCHAR(30) NOT NULL,
	AddressID INT REFERENCES AddressRecords(AddressID),
	PhoneNo VARCHAR(14) NOT NULL,
	MailID VARCHAR(50) NOT NULL,
	DOB DATE NOT NULL,
	Gender VARCHAR(10) NOT NULL,
	PrimaryDrID INT REFERENCES Employees(EmpID),
	PRIMARY KEY (PatientID)
);

/*	CREATE Emergency Records TABLE - ToothHeavenDentistry	*/
CREATE TABLE EmergencyRecords(
	PatientID INT REFERENCES PatientInfo(PatientID),
	EmergencyContactFName VARCHAR(30) NOT NULL,
	EmergencyContactLName VARCHAR(30) NOT NULL,
	EmergencyPhoneNo VARCHAR(14) NOT NULL,
	EmergencyMailID VARCHAR(50),
	EmergencyAddressID INT REFERENCES AddressRecords(AddressID),
	PRIMARY KEY (PatientID)
);

/*	CREATE Consent TABLE - ToothHeavenDentistry	*/
CREATE TABLE Consent(
	ConsentID INT IDENTITY(1,1) NOT NULL UNIQUE,
	PatientID INT REFERENCES PatientInfo(PatientID),
	isSigned INT NOT NULL,
	PRIMARY KEY (ConsentID)
);

/*	CREATE Medical History TABLE - ToothHeavenDentistry	*/
CREATE TABLE MedicalHistory(
	PatientID INT REFERENCES PatientInfo(PatientID),
	Pregnant INT NOT NULL,
	HIV INT NOT NULL,
	HeartCondition INT NOT NULL,
	Asthma INT NOT NULL,
	OtherSymptoms CHAR(100),
	PRIMARY KEY (PatientID)
);

/*	CREATE Other Medications TABLE - ToothHeavenDentistry	*/
CREATE TABLE OtherMedications(
	MedicationID INT IDENTITY(1,1) NOT NULL UNIQUE,
	PatientID INT REFERENCES PatientInfo(PatientID),
	MedicineName VARCHAR(50) NOT NULL,
	Purpose VARCHAR(70) NOT NULL,
	PRIMARY KEY (MedicationID)
);

/*	CREATE Dental History TABLE - ToothHeavenDentistry	*/
CREATE TABLE DentalHistory(
	PatientID INT REFERENCES PatientInfo(PatientID) UNIQUE,
	NameLastDentist VARCHAR(50),
	DateOfLastVisit DATE,
	DentistVisits INT,
	Questions VARCHAR(255),
	PRIMARY KEY (PatientID)
);

/*	CREATE Appointments TABLE - ToothHeavenDentistry	*/
CREATE TABLE Appointments(
	AppntID INT IDENTITY(1,1) NOT NULL UNIQUE,
	AppntTypeID INT REFERENCES AppointmentType(AppntTypeID),
	PatientID INT REFERENCES PatientInfo(PatientID),
	EmpID INT REFERENCES Employees(EmpID),
	RoomID INT REFERENCES Rooms(RoomID),
	SchedID INT REFERENCES AppointmentSchedule(SchedID),
	PRIMARY KEY (AppntID)
);

/*	CREATE Prescriptions TABLE - ToothHeavenDentistry	*/
CREATE TABLE Prescriptions(
	PrescriptionID INT IDENTITY(1,1) NOT NULL UNIQUE,
	AppntID INT REFERENCES Appointments(AppntID),
	DrugID INT REFERENCES DrugRecords(DrugID),
	Dosage VARCHAR(50),
	PRIMARY KEY (PrescriptionID)
);

/*	CREATE Insurance Info TABLE - ToothHeavenDentistry	*/
CREATE TABLE InsuranceInfo(
	InsuranceNo BIGINT NOT NULL,
	PatientID INT REFERENCES PatientInfo(PatientID),
	SubscriberFName VARCHAR(30),
	SubscriberLName VARCHAR(30),
	SubscriberAddressID INT REFERENCES AddressRecords(AddressID),
	RelationshipToPatient VARCHAR(20),
	ProviderCompany VARCHAR(30),
	PolicyNo VARCHAR(20),
	CertificateNo VARCHAR(20),
	Description VARCHAR(255),
	MaxCoverage MONEY,
	PRIMARY KEY (InsuranceNo, PatientID)
);

/*	CREATE Allergies TABLE - ToothHeavenDentistry	*/
CREATE TABLE Allergies(
	PatientID INT REFERENCES PatientInfo(PatientID),
	VisitDate DATE,
	Antibiotics INT,
	Aspirin INT,
	Codeine INT,
	Darvon INT,
	LocalAnaesthetic INT,
	NitrousOxide INT,
	Others VARCHAR(255),
	PRIMARY KEY (PatientID, VisitDate)
);

/*	CREATE COVID Disclosures TABLE - ToothHeavenDentistry	*/
CREATE TABLE COVIDDisclosures(
	PatientID INT REFERENCES PatientInfo(PatientID),
	VisitDate DATE,
	Cough INT,
	Fever INT,
	SoreThroat INT,
	FourteenDayExposure INT,
	PRIMARY KEY (PatientID, VisitDate)
);

/*	CREATE Dental Records TABLE - ToothHeavenDentistry	*/
CREATE TABLE DentalRecords(
	RecordID INT IDENTITY (1,1) NOT NULL UNIQUE,
	PatientID INT REFERENCES PatientInfo(PatientID),
	AppntID INT REFERENCES Appointments(AppntID),
	Comments VARCHAR(255),
	DescriptionOfProcedure VARCHAR(255),
	ToothAssociated VARCHAR(20),
	ProcedureOutcome VARCHAR(255),
	PRIMARY KEY (RecordID)
);

raiserror('TABLE CREATION COMPLETED SUCCESSFULLY...',0,1)
GO

raiserror('INSERTING DATA INTO TABLES...',0,1)
GO

-- Appointment Schedule
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','11:15:00','12:15:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','12:30:00','12:45:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','13:00:00','13:20:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','14:00:00','14:45:00',1);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','15:00:00','15:50:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','16:00:00','16:25:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','17:00:00','17:30:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','18:00:00','18:17:00',1);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-09','19:00:00','19:23:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-14','20:00:00','20:29:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-14','09:00:00','09:40:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-14','10:00:00','10:45:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-14','11:00:00','11:55:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-15','08:00:00','08:21:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-15','09:00:00','09:34:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-15','10:00:00','10:33:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-15','11:00:00','11:26:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-15','12:00:00','12:37:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-15','14:00:00','14:58:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-16','08:00:00','08:13:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-16','09:00:00','09:34:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-16','10:00:00','10:09:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-16','11:00:00','11:10:00',1);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','11:15:00','11:17:00',1);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','12:30:00','12:59:00',1);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','13:00:00','13:23:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','14:00:00','14:25:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','15:00:00','15:55:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','16:00:00','16:37:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','17:00:00','17:48:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','18:00:00','18:30:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-17','19:00:00','19:30:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-18','08:00:00','08:13:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-18','09:00:00','09:34:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-18','10:00:00','10:09:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-18','11:00:00','11:10:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-19','11:15:00','11:25:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-19','12:30:00','12:59:00',1);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-19','13:00:00','13:23:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-19','14:00:00','14:25:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-19','15:00:00','15:55:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-19','16:00:00','16:37:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-20','17:00:00','17:48:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-20','08:00:00','08:30:00',0);
INSERT INTO AppointmentSchedule (Date,StartTime,EndTime,isCancelled) VALUES ('2021-12-20','09:00:00','09:35:00',0);

--Appointment type
INSERT INTO AppointmentType (TypeName) VALUES ('Emergency');
INSERT INTO AppointmentType (TypeName) VALUES ('Regular check-up');
INSERT INTO AppointmentType (TypeName) VALUES ('Consultation');
INSERT INTO AppointmentType (TypeName) VALUES ('Hygienic');
INSERT INTO AppointmentType (TypeName) VALUES ('Surgery');

--Drug records
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Ibuprofen','Toothache','Oral Ingestion advised',20);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Aspirin','Toothache','Oral Ingestion advised',25);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Diclofenac','Toothache','Oral Ingestion advised',15);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Paracetamol','Toothache','Oral Ingestion advised',10);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Diazepam','Toothache','To be taken as prescribed by doctor',20);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Orabase-HCA','Anti-inflammatory','To be taken as prescribed by',30);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Oracort','Anti-inflammatory','To be taken as prescribed by',15);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Oralone','Anti-inflammatory','To be taken as prescribed by',55);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Lide','Anti-inflammatory','To be taken as prescribed by',25);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Temovate','Anti-inflammatory','To be taken as prescribed by',25);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Ambesol','Painkiller','To be taken as prescribed by',60);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Chloraseptic','Painkiller','To be taken as prescribed by',70);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Orajel','Painkiller','To be taken as prescribed by',35);
 
INSERT INTO DrugRecords (DrugName,Description,Usage,Price) 
VALUES('Xylocaine','Painkiller','To be taken as prescribed by',40);

--EmployeeTypes
INSERT INTO EmployeeTypes (JobTitle) VALUES ('Hygienist');
INSERT INTO EmployeeTypes (JobTitle) VALUES ('Dentist');

--ADDRESS RECORDS
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('123 Main St, #31','Boston','MA ','90024');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('123 Main St, #11','Boston','MA ','90210');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 15','Cambridge','MA ','91120');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Carter Drive, City Sq #01','Los Angeles','CA ','91210');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Carter Drive, City Sq #02','Los Angeles','CA','90211');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Carter Drive, City Sq #03','Los Angeles','CA','92102');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 5th','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 6th','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 7th','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('23th Avenue, 47th, #90','New York','NY','10468');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('23th Avenue, 47th, #91','New York','NY','11389');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('23th Avenue, 47th, #92','New York','NY','10306');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('23th Avenue, 47th, #93','New York','NY','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Maddy Ave, Apt. 404','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Maddy Ave, Apt. 405','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Maddy Ave, Apt. 411','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Maddy Ave, Apt. 4','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Maddy Ave, Apt. 4','Atlanta','GA','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Saddy Ave, Apt. 400','Atlanta','GA','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('500 Saddy Ave, Apt. 423','Atlanta','GA','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('123 Main St, #35','Boston','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Park Drive St, #31','Boston','MA ','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Park Drive St, #21','Boston','MA ','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 16','Cambridge','MA ','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('23th Avenue, 47th, #099','New York','NY','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 8th','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 9th','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 10th','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 11','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 12','Atlanta','GA','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 13','Atlanta','GA','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 14','Atlanta','GA','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #1','Boston','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #2','Boston','MA ','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #3','Boston','MA ','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 17','Cambridge','MA ','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('7th Avenue, 47th, #93','New York','NY','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 14','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 15','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 16','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 17','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 18','Atlanta','GA','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 19','Atlanta','GA','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 20','Atlanta','GA','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #4','Boston','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #5','Boston','MA ','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #6','Boston','MA ','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 19','Cambridge','MA ','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('7th Avenue, 47th, #9','New York','NY','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 20','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 21','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 22','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 23','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 24','Atlanta','GA','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 25','Atlanta','GA','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 26','Atlanta','GA','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #7','Boston','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #8','Boston','MA ','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #9','Boston','MA ','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 20','Cambridge','MA ','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('23th Avenue, 47th, #55','New York','NY','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 26','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 27','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 28','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 29','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 30','Atlanta','GA','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 31','Atlanta','GA','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Crement Garden, City Hall 32','Atlanta','GA','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #10','Boston','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #11','Boston','MA ','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #12','Boston','MA ','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 32','Cambridge','MA ','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('7th Avenue, 47th, #7','New York','NY','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 100','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 101','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 102','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 103','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 104','Atlanta','GA','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 105','Atlanta','GA','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 106','Atlanta','GA','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #15','Boston','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('8thth Avenue, 47th, #93','New York','NY','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 107','Atlanta','GA','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 108','Atlanta','GA','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 109','Atlanta','GA','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 110','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 111','Atlanta','GA','30303');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 112','Atlanta','GA','30305');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 113','Atlanta','GA','30307');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #16','Boston','MA ','30309');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #17','Boston','MA ','30311');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Longwood Area, JVie #18','Boston','MA ','30312');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 34','Cambridge','MA ','02215');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('8th Avenue, 47th, #31','New York','NY','02115');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 120','Atlanta','GA','02213');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 121','Atlanta','GA','02225');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 122','Atlanta','GA','11706');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 123','Atlanta','GA','30301');
INSERT INTO AddressRecords (Street,City,State,Zip) VALUES ('Jiggins Road, Row 124','Atlanta','GA','30303');

--Employees 
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (1,'Ken','Sánchez',1012,'8292992092','Ken@gmail.com','1998-09-01','Male','1234567890');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Terri','Duffy',1013,'7207779780','Terri@gmail.com','1995-09-03','Female','1234567891');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (1,'Roberto','Tamburello',1014,'9848383847','Roberto@gmail.com','1995-09-03','Male');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Rob','Walters',1015,'7898087663','Rob@gmail.com','1995-09-03','Male','1234567893');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Gail','Erickson',1016,'9874573636','Gail@gmail.com','1988-02-03','Female','1234567894');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (2,'Jossefine','Goldberg',1017,'9020202473','Jossef@gmail.com','1995-09-03','Female');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Dylan','Miller',1018,'8907654678','Dylan@gmail.com','1990-12-09','Male','1234567896');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (2,'Diane','Margheim',1019,'9084746378','Diane@gmail.com','1995-09-03','Female');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Gigi','Matthew',1020,'8765436578','Gigi@gmail.com','1995-09-03','Female','1234567898');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Michael','Raheem',1021,'9087654321','Michael@gmail.com','1995-09-03','Male','1234567899');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (2,'Ovidiu','Cracium',1022,'7890654321','Ovidiu@gmail.com','1994-03-01','Male');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (1,'Thierry','DHers',1023,'7657659870','Thierry@gmail.com','1996-12-09','Female');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (1,'Janice','Galvin',1024,'7657658902','Janice@gmail.com','1995-11-01','Female','1234567902');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (1,'Michael','Sullivan',1025,'7657652431','Michael@gmail.com','1996-12-09','Male');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (1,'Sharon','Salavaria',1026,'7890987654','Sharon@gmail.com','1995-09-03','Female');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (1,'David','Bradley',1027,'9876543765','David@gmail.com','1996-12-09','Male','1234567905');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (1,'Kevin','Brown',1028,'9870987654','Kevin@gmail.com','2000-12-12','Male','1234567906');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (1,'John','Wood',1029,'9089089087','John@gmail.com','1996-12-09','Male','1234567907');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (1,'Mary','Dempsey',1030,'9809809805','Mary@gmail.com','1996-12-09','Female');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (2,'Wanida','Benshoof',1031,'9809867354','Wanida@gmail.com','1995-09-03','Female','1234567909');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (2,'Terry','Eminhizer',1032,'9089089765','Terry@gmail.com','1996-12-09','Male');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,NPINumber) Values (1,'Sariya','Harnpadoungsataya',1033,'8976543678','Sariya@gmail.com','1978-07-12','Female','1234567911');
INSERT INTO Employees (TypeID,FName,LName,AddressID,PhoneNo,MailID,DOB,Gender) Values (1,'Mary','Gibson',1034,'9089099090','Mary@gmail.com','1997-09-12','Female');

--Doctor Specializations
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210001,'Prosthodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210002,'Periodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210001,'Oral and Maxillofacial Surgery');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210002,'Conservative Dentistry');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210005,'Orthodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210005,'Oral Pathology');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210005,'Community Dentistry');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210008,'Paedodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210008,'Oral Medicine and Radiology');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210008,'Periodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210010,'Oral Pathology');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210010,'Periodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210013,'Hygienist');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210014,'Oral and Maxillofacial Surgery');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210015,'Periodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210016,'Oral Pathology');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210017,'Community Dentistry');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210018,'Paedodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210019,'Hygienist');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210020,'Oral and Maxillofacial Surgery');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210021,'Oral Pathology');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210022,'Paedodontics');
INSERT INTO DoctorSpecializations (EmpID,SpecializationName) VALUES (20210022,'Oral Pathology');

SET IDENTITY_INSERT ClinicLocation OFF

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('5758333333',1000,'Tooth Heaven - Boston, Fenway',3,3);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('6712345678',1001,'Tooth Heaven - Boston, Longwood, Fenway',2,4);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('6220106666',1002,'Tooth Heaven - Cambridge, Fenway',2,4);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('7236271931',1003,'Tooth Heaven - Los Angeles, Sunset Dr, Fenway',5,7);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('6839290231',1004,'Tooth Heaven - Los Angeles, Hollywood Hills, Fenway',4,5);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('6753222222',1005,'Tooth Heaven - Los Angeles, Beverly Hills',5,8);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('7638299342',1006,'Tooth Heaven - Atlanta, Cherokee',3,4);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('9733774922',1007,'Tooth Heaven - Atlanta, S. Gwinett, Fenway',2,2);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('7883003832',1008,'Tooth Heaven - Atlanta, Buckhead',4,4);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('7938277723',1009,'Tooth Heaven - New York, Hells Kitchen, Fenway',2,2);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('9893939721',1010,'Tooth Heaven - New York, DUMBO',2,3);

INSERT INTO ClinicLocation(PhoneNo,AddressID,Name,NoOfFloors,NoOfRooms)
VALUES ('9893773492',1011,'Tooth Heaven - New York, Harlem, Fenway',4,6);


--rooms 
INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (1,'Hygienist',3);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (1,'General',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (1,'Endodontic',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (1,'Emergency',4);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (2,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (2,'Hygienist',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (2,'Emergency',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (2,'General',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (3,'Hygienist',4);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (3,'Orthodontic',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (3,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (3,'Hygienist',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (4,'Emergency',5);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (4,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (4,'Orthodontic',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (4,'General',4);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (4,'Hygienist',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (5,'Endodontic',3);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (5,'Hygienist',5);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (5,'Emergency',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (5,'General',4);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (6,'Orthodontic',5);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (6,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (7,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (7,'Hygienist',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (8,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (8,'Hygienist',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (9,'General',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (9,'Hygienist',1);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (10,'General',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (10,'Hygienist',3);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (11,'General',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (11,'Hygienist',2);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (12,'General',3);

INSERT INTO ROOMS(ClinicID,RoomType,RoomFloor)
VALUES (12,'Hygienist',2);


--equipments
INSERT INTO Equipments(RoomID,EquipName)
VALUES (33,'Mouth Mirror');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (33,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (21,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (19,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (1,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (3,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (4,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (5,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (34,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (35,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (1,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (6,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (7,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (8,'Cotton Pliers');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (9,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (10,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (11,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (12,'Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (13,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (14,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (15,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (16,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (17,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (2,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (18,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (20,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (22,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (23,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (24,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (25,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (26,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (27,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (28,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (29,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (30,'Endo Excavator');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (31,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (32,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (1,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (3,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (4,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (5,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (1,'Mouth Mirror');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (6,'Mouth Mirror');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (7,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (8,'Endo Explorer');

INSERT INTO Equipments(RoomID,EquipName)
VALUES (9,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (10,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (11,'Endo Explorer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (12,'Nabers Probe');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (2,'Tweezer');
 
INSERT INTO Equipments(RoomID,EquipName)
VALUES (2,'Endo Excavator');

--pharamcy
INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES(1,1,210);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (2,2,100);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (3,3,70);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (4,4,85);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (5,5,102);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (6,6,24);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (7,7,300); 

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES(8,8,200);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (9,9,410);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (10,10,56);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (12,11,80);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (13,12,200);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (14,1,391);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (14,2,330);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (1,3,200)

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (2,4,322);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (3,5,484);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty) 
VALUES (4,6,55);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (5,7,34);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (6,8,455);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (7,9,481);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (8,10,990);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (9,11,221);

INSERT INTO Pharmacy (DrugID, ClinicID, Qty)
VALUES (10,12,2);


--Patient Info
INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('OLIVER','SMITH',1035,'9897898789','Oliver@gmail.com','1995-12-12','MALE',20210001);

INSERT INTO PatientInfo ( FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('GEORGE','JONES',1036,'9809807654','George@gmail.com','1992-12-09','MALE',20210002);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('ARTHUR','WILLIAMS',1037,'7890987654','Arthur@gmail.com','1997-07-09','MALE',20210003);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('NOAH','TAYLOR',1038,'7890987645','Noah@gmail.com','1995-06-09','MALE',20210004);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('ZOYA','JOHNSON',1039,'8790987654','Zoya@gmail.com','1995-10-09','FEMALE',20210005);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('LYRA','CLARK',1040,'7890908765','Lyra@gmail.com','1995-10-09','FEMALE',20210006);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('HALLIE','WRIGHT',1041,'7689078900','Hallie@gmail.com','1995-09-03','FEMALE',20210007);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('ALYSSA','GREEN',1042,'8909890876','Alyssa@gmail.com','1993-02-03','FEMALE',20210008);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('STELLA','COOPER',1043,'8906543675','Stella@gmail.com','1988-02-03','FEMALE',20210009);

INSERT INTO PatientInfo (FName, LName, AddressID, PhoneNo, MailID, DOB, Gender, PrimaryDrID) 
VALUES ('MILO','GELLER', 1044,'8908765432','Milo@gmail.com','1996-12-23','MALE',20210006);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Theo','Bailey',1045,'7890765432','Theo@gmail.com','1995-10-09','Male',20210007);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID)
VALUES('Araminta','Lee',1046,'8907643425','Araminta@gmail.com','1995-10-09','Female',20210008);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Stella','Cox',1047,'9090907654','stella@gmail.com','1995-10-09','Female',20210009);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Mark','Khan',1048,'9898987654','Mark@gmail.com','1995-10-09','Male',20210014);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Nick','Young',1049,'9876543678','Nick@gmail.com','1995-10-09','Male',20210015);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Harry','Philips', 1050,'9837546357','harry@gmail.com','1995-10-09','Male',20210016);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('John','Yang',1051,'9090876543','john@gmail.com','1995-10-09','Male',20210017);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Miles','Russo', 1052,'9897969594','Miles@gmail.com','1995-10-09','Male',20210018);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Peter','Romano',1053,'9098909876','Peter@gmail.com','1995-10-09','Male',20210019);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Ray','Rodriguez',1054,'8908907654','Ray@gmail.com','1995-10-09','Male',20210020);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Ninna','Ricci',1055,'8765463212','Ninna@gmail.com','1995-10-09','Female',20210021);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Anna','Hadid', 1056,'9839098763','Anna@gmail.com','2000-12-12','Female',20210022);
 
INSERT INTO PatientInfo(FName,LName,AddressID,PhoneNo,MailID,DOB,Gender,PrimaryDrID) 
VALUES('Annabelle','Reynolds', 1057,'8907654323','Annabelle@gmail.com','1996-12-09','Female',20210020);


--Emergency Records
INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12000,'Phoebe','Alvarez','9897898789','Alvarez@gmail.com',1058);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12001,'Eva','Jones','9809807654','Jones@gmail.com',1059);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12002,'Ava','Jonas','7890987654','Jones@gmail.com',1060);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12003,'Alice','Anderson','7890987645','Jones@gmail.com',1061);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12004,'Chloe','Thomson','8790987654','Thomson@gmail.com',1062);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12005,'Sophia','Tremblay','7890908765','Thomson@gmail.com',1063);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12006,'Ella','Martin','7689078900','Martin@gmail.co',1064);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12007,'Charlotte','Tillbury','8909890876','Martin@gmail.com',1065);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12008,'Ruby','LeBlanc','8906543675','LeBlanc@gmail.com',1066);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12009,'Jessica','White','8908765432','LeBlanc@gmail.com',1067);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12010,'Freya','Reid','7890765432','LeBlanc@gmail.com',1068);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12011,'Alfie','Young','8907643425','Young@gmail.com',1069);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12012,'James','Murray','9090907654','Murray@gmail.com',1070);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12013,'Logan','Hall','9898987654','Murray@gmail.com',1071);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12014,'Daniel','Hill','9876543678','Hill@gmail.com',1072);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12015,'Leo','Harries','9837546357','Harries@gmail.com',1073);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12016,'Samuel','Nguyen','9090876543','Nguyen@gmail.com',1074);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12017,'Harrison','Gill','9897969594','Gill@gmail.com',1075);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12018,'Edward','Grant','9098909876','Grant@gmail.com',1076);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12019,'Alex','Evans','8908907654','Evans@gmail.com',1077);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12020,'Jack','Liu','8765463212','Liu@gmail.com',1078);

INSERT INTO EmergencyRecords(PatientID,EmergencyContactFName,EmergencyContactLName,EmergencyPhoneNo,EmergencyMailID,EmergencyAddressID) 
VALUES(12021,'Cody','Marshal','9839098763','Marshall@gmail.com',1079);


--CONSENT
INSERT INTO Consent (PatientID,isSigned) VALUES (12000,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12001,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12002,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12003,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12004,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12005,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12006,0);
INSERT INTO Consent (PatientID,isSigned) VALUES (12007,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12008,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12009,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12010,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12011,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12012,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12013,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12014,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12015,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12016,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12017,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12018,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12019,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12020,0);
INSERT INTO Consent (PatientID,isSigned) VALUES (12021,1);
INSERT INTO Consent (PatientID,isSigned) VALUES (12022,1);

--Medical History
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12000,0,0,0,0,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12001,1,0,0,0,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12002,0,0,0,0,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12003,0,0,0,0,'TB');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12004,0,0,1,0,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12005,0,0,1,1,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12006,0,0,0,1,'TB');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12007,0,0,0,0,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12008,0,0,0,0,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12009,0,0,0,0,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12010,0,0,0,0,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12011,0,0,0,0,'TB ');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12012,0,0,0,1,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12013,0,0,0,1,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12014,0,0,0,0,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12015,0,0,1,0,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12016,0,0,0,0,'TB');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12017,0,0,1,1,'Ulcer');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12018,0,0,1,1,'TB');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12019,0,0,0,1,'Sinus');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12020,0,0,0,1,'TB');
INSERT INTO MedicalHistory (PatientID,Pregnant,HIV,HeartCondition,Asthma,OtherSymptoms) VALUES (12021,0,0,0,0,'Sinus');


-- OTHERMEDICATIONS
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12000,'Abelcet','Neck Pain ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12001,'Abilify','Eye Pain ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12002,'Abraxane','Ear Pain');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12002,'Acamprosate Calcium','Acidity ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12004,'Acarbose','Tonsils');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12005,'Accolate','Headache ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12006,'Accretropin','Heart Burn ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12007,'AccuNeb','Migrain ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12008,'Accupril','Ulcers');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12008,'Accutane','Hear Burn ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12008,'Acebutolol','Acid Reflux ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12011,'Aceon','Minor Burns ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12012,'Acetadote','Injury Cut ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12013,'Acetaminophen','Stomach Infection ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12014,'Acetic Acid','Mouth Ulcers');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12015,'Aci-Jel','Urine Infection ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12016,'Aciphex','Swelling ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12016,'Acitretin','Red Eyes ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12016,'Aclovate','Diseases');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12019,'Acrivastine and Pseudoephedrine','Fever ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12020,'Actemra','Cold ');
INSERT INTO OtherMedications (PatientID,MedicineName,Purpose) VALUES (12021,'Acthrel','Cough');

--DENTAL HISTORY 
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12000,'Kevin Verghese','2021-11-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12001,'Steffi Simon','2021-12-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12002,'Gloria Pritchett','2021-12-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12003,'Claire Dunphy','2021-10-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12004,'Andrew Leung','2021-09-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12005,'Derek Schmidt','2021-08-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12006,'Mindy Malhotra','2021-07-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12007,'Kelly Kapoor','2021-06-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12008,'Jason Isaac','2021-05-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12009,'Jill Williams','2021-04-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12010,'James Hamilton','2021-03-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12011,'Peter Krebs','2021-01-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12012,'Jo Brown','2021-12-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12013,'Guy Gilbert','2021-12-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12014,'Mark McArthur','2021-01-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12015,'Britta Simon','2021-02-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12016,'Margie Shoop','2021-03-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12017,'Rebecca Laszlo','2021-04-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12018,'Ed Dudenhoefer','2021-05-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12019,'JoLynn Dobney','2021-06-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12020,'Bryan Baker','2021-07-12',3,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12021,'James Kramer','2021-08-12',1,'Have you encountered any specific side effects from previous visits/treatments? No');
INSERT INTO DentalHistory (PatientID,NameLastDentist,DateOfLastVisit,DentistVisits,Questions) VALUES (12022,'Nancy Anderson','2021-09-12',2,'Have you encountered any specific side effects from previous visits/treatments? No');

-- Appointments
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID)
VALUES (1,12000,20210001,20,1);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (2,12001,20210002,5,2);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (1,12002,20210003,20,3);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (2,12003,20210004,8,4);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (3,12004,20210005,2,5);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (4,12005,20210020,1,6);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (5,12006,20210021,22,7);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (4,12007,20210022,6,8);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (4,12008,20210020,9,9);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (3,12009,20210006,26,10);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (2,12010,20210007,2,11);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (1,12011,20210001,13,12);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (2,12012,20210002,11,13);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (2,12013,20210003,11,14);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (3,12014,20210004,28,15);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (4,12015,20210005,9,16);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (4,12016,20210006,6,17);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (5,12017,20210022,10,18);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (4,12018,20210010,17,19);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) 
VALUES (3,12019,20210011,26,20);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (2,12020,20210014,14,21);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (2,12021,20210001,16,22);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (1,12022,20210002,7,23);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (3,12015,20210022,23,24);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12016,20210020,11,25);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (5,12017,20210006,10,26);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12018,20210007,19,27);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12019,20210001,25,28);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (3,12020,20210002,23,29);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (2,12021,20210003,23,30);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (1,12022,20210022,4,31);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (5,12001,20210020,3,32);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12002,20210007,1,33);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (5,12003,20210001,22,34);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12004,20210002,9,35);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12005,20210003,1,36);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (3,12006,20210004,3,37);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (2,12007,20210005,2,38);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (1,12008,20210006,4,39);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (5,12009,20210017,3,40);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12010,20210010,19,41);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (5,12011,20210011,18,42);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12012,20210007,25,43);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (4,12013,20210001,27,44);
INSERT INTO Appointments (AppntTypeID,PatientID,EmpID,RoomID,SchedID) VALUES (3,12014,20210002,18,45);

--Prescriptions
INSERT INTO Prescriptions (AppntID, DrugID, Dosage) 
VALUES (1,12,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (2,12,'1 TIME A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (2,11,'1 TIME A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (3,12,'3 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (5,3,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (6,3,'3 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (6,5,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (6,6,'3 TIMES A DAY');

INSERT INTO Prescriptions ( AppntID, DrugID, Dosage)
VALUES (6,7,'1 TIME A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (8,1,'3 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (8,2,'1 TIME A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (9,3,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES  (10,2,'3 TIMES A DAY');

INSERT INTO Prescriptions ( AppntID, DrugID, Dosage)
VALUES (11,8,'3 TIMES A DAY');

INSERT INTO Prescriptions ( AppntID, DrugID, Dosage)
VALUES (12,9,'3 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (13,10,'1 TIME A DAY');

INSERT INTO Prescriptions ( AppntID, DrugID, Dosage)
VALUES (15,11,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (16,13,'3 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (17,14,'2 TIMES A DAY');

INSERT INTO Prescriptions ( AppntID, DrugID, Dosage)
VALUES (18,14,'1 TIME A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (19,11,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (20,3,'2 TIMES A DAY');

INSERT INTO Prescriptions (AppntID, DrugID, Dosage)
VALUES (21,3,'1 TIME A DAY');

--INSURANCE INFO
select * from AddressRecords
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1010,12000,'Oliver','Smith',1000,'Self','Amica Insurance',9100,'1283223828','Accidental and Health',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1011,12001,'Sebastian','Wilder',1081,'Father','Blue Cross',9101,'3848484384','Full coverage',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1012,12002,'Arthur','Williams',1037,'Self','Amica Insurance',9102,'298922','Dental Insurance only',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1013,12003,'Ethan','Wilde',1082,'Father','Humana',9103,'2','Health emergency ',$20000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1014,12004,'Benjamin','Wert',1083,'Mother ','Blue Cross',9104,'223322','Full Coverage',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1015,12005,'Elijah','Yui',1084,'Spouse','Amica Insurance',9105,'323244','Health emergency',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1016,12006,'Alex','Kali',1085,'Family','Blue Cross',9100,'54543343','Dental Insurance only',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1017,12007,'Oliver','Jordan',1086,'Bother','Humana',9107,'5433222334','Full Coverage',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1018,12006,'Liam ','Jayden',1087,'Spouse','Blue Cross',9108,'119454565656','Health emergency',$20000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1019,12009,'Ben ','James',1088,'Brother','Humana',9100,'120464545','Full Coverage',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1020,12006,'Theo','Bailey',1045,'Self','Amica Insurance',9110,'58845844','Dental Insurance only',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1021,12011,'Camila','Jilan',1089,'Mother ','Blue Cross',9111,'45534433','Health emergency',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1022,12012,'Mia','Gally',1090,'Spouse ','Amica Insurance',9100,'2332233223','Full Coverage',$20000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1023,12013,'Emma','Rally',1091,'Sister','Blue Cross',9100,'23232345','Health emergency',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1024,12014,'Gianna','Rad',1092,'Mother ','Amica Insurance',9100,'7667766776','Dental Insurance only',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1025,12015,'Luna','Thorp',1093,'Spouse ','Amica Insurance',9115,'48381284','Full Coverage',$20000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1026,12016,'Sofia','Kai',1094,'Mother ','Blue Cross',9100,'8232378','Health emergency',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1027,12017,'Miles','Russo',1052,'Self','Humana',9117,'12823487478','Dental Insurance only',$10000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1028,12018,'Ginny','Jina',1095,'Brother','Humana',9100,'129349439','Dental Insurance only',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1029,12019,'Ray','Rodriguez',1096,'Self','Blue Cross',9119,'13084948','Health emergency',$20000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1030,12018,'Maya','Helly',1097,'Brother','Amica Insurance',9120,'458945899845','Health emergency',$20000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1031,12021,'Anna','Hadid',1056,'Self','Humana',9108,'89459845','Health emergency ',$15000.00);
INSERT INTO InsuranceInfo (InsuranceNo,PatientID,SubscriberFName,SubscriberLName,SubscriberAddressID,RelationshipToPatient,ProviderCompany,PolicyNo,CertificateNo,Description ,MaxCoverage) VALUES (1032,12018,'Gwen','Stacy',1098,'Brother','Humana',9122,'59889','Full Coverage',$10000.00);




--ALLERGIES
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12000,'2021-12-09',0,0,1,1,1,1,'Peanuts');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12001,'2021-12-09',1,0,1,1,1,1,'Peanuts');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12002,'2021-12-09',1,0,1,1,1,1,'Shrimp');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12003,'2021-12-09',1,1,0,0,0,1,'Peanuts');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12004,'2021-12-09',0,1,0,0,0,1,'Milk');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12005,'2021-12-09',0,1,0,0,0,0,'Dry fruits');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12006,'2021-12-09',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12007,'2021-12-09',0,0,0,1,1,0,'Fish');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12008,'2021-12-09',1,1,0,0,1,1);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12009,'2021-12-14',1,0,1,1,1,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12010,'2021-12-14',0,1,1,0,1,0,'Shrimp');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12011,'2021-12-14',0,0,1,1,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12012,'2021-12-14',1,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12013,'2021-12-15',0,1,0,0,0,1,'Avacado');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12014,'2021-12-15',0,1,1,0,1,1);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12015,'2021-12-15',0,0,0,1,1,1,'Fish');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12016,'2021-12-15',1,0,1,1,0,1,'Lactose');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12017,'2021-12-15',1,1,0,0,1,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12018,'2021-12-15',0,1,1,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12019,'2021-12-16',0,0,0,0,0,0,'Lactose');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12020,'2021-12-16',0,0,0,1,1,1,'Sea food');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12021,'2021-12-16',1,0,0,1,1,1);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12022,'2021-12-16',1,1,1,1,0,1);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12015,'2021-12-17',0,0,0,0,0,0,'Sea food');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12016,'2021-12-17',0,0,0,0,0,0,'Lactose');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12017,'2021-12-17',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12018,'2021-12-17',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12019,'2021-12-17',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12020,'2021-12-17',0,0,0,0,0,0,'Sea food');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12021,'2021-12-17',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12022,'2021-12-17',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12001,'2021-12-17',0,0,0,0,0,0,'Peanuts ');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12002,'2021-12-18',0,0,0,0,0,0,'Shrimp ');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12003,'2021-12-18',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12004,'2021-12-18',0,0,0,0,0,0,'Milk');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12005,'2021-12-18',0,0,0,0,0,0,'Dry fruits');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12006,'2021-12-19',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12007,'2021-12-19',0,0,0,0,0,0,'Fish');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12008,'2021-12-19',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12009,'2021-12-19',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12010,'2021-12-19',0,0,0,0,0,0,'Shrimp');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12011,'2021-12-19',0,0,0,0,0,0);
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12012,'2021-12-20',0,0,0,0,0,0,'Avacado ');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide,Others) VALUES (12013,'2021-12-20',0,0,0,0,0,0,'Avacado ');
INSERT INTO Allergies (PatientId,VisitDate,Antibiotics,Aspirin,Codeine,Darvon,LocalAnaesthetic,NitrousOxide) VALUES (12014,'2021-12-20',0,0,0,0,0,0);


--COVID DISCLOSURES
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12000,'2021-12-09',1,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12001,'2021-12-09',1,0,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12002,'2021-12-09',1,0,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12003,'2021-12-09',0,1,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12004,'2021-12-09',0,1,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12005,'2021-12-09',0,1,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12006,'2021-12-09',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12007,'2021-12-09',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12008,'2021-12-09',0,1,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12009,'2021-12-14',1,0,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12010,'2021-12-14',1,1,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12011,'2021-12-14',1,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12012,'2021-12-14',0,0,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12013,'2021-12-15',0,1,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12014,'2021-12-15',1,1,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12015,'2021-12-15',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12016,'2021-12-15',1,0,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12017,'2021-12-15',0,1,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12018,'2021-12-15',1,1,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12019,'2021-12-16',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12020,'2021-12-16',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12021,'2021-12-16',0,0,1,1);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12022,'2021-12-16',1,1,1,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12015,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12016,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12017,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12018,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12019,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12020,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12021,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12022,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12001,'2021-12-17',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12002,'2021-12-18',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12003,'2021-12-18',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12004,'2021-12-18',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12005,'2021-12-18',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12006,'2021-12-19',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12007,'2021-12-19',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12008,'2021-12-19',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12009,'2021-12-19',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12010,'2021-12-19',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12011,'2021-12-19',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12012,'2021-12-20',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12013,'2021-12-20',0,0,0,0);
INSERT INTO COVIDDisclosures (PatientId,VisitDate,Cough,Fever,SoreThroat,FourteenDayExposure) VALUES (12014,'2021-12-20',0,0,0,0);


--Dental Records
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12000,1,'Extractions','Incisors','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12001,2,'Fillings','Wisdom tooth','Need a second sitting ');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12002,3,'Veneers','Premolars','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12003,4,'Root Canal','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12004,5,'Veneers','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12005,6,'Extractions','Premolars','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12006,7,'Veneers','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12007,8,'Fillings','Premolars','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12008,9,'Veneers','Wisdom tooth','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12009,10,'Extractions','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12010,11,'Root Canal','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12011,12,'Veneers','Premolars','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12012,13,'Fillings','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12013,14,'Extractions','Wisdom tooth','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12014,15,'Root Canal','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12015,16,'Extractions','Incisors','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12016,17,'Veneers','Wisdom tooth','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12017,18,'Fillings','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12018,19,'Root Canal','Premolars','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12019,20,'Extractions','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12020,21,'Veneers','Wisdom tooth','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12021,22,'Root Canal','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12022,23,'Extractions','Incisors','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12015,24,'Extractions','Incisors','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12016,25,'Fillings','Wisdom tooth','Need a second sitting ');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12017,26,'Veneers','Premolars','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12018,27,'Root Canal','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12019,28,'Veneers','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12020,29,'Extractions','Premolars','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12021,30,'Veneers','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12022,31,'Fillings','Premolars','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12001,32,'Veneers','Wisdom tooth','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12002,33,'Extractions','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12003,34,'Root Canal','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12004,35,'Veneers','Premolars','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12005,36,'Root Canal','Incisors','Need a second sitting ');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12006,37,'Extractions','Wisdom tooth','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12007,38,'Veneers','Wisdom tooth','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12008,39,'Root Canal','Incisors','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12009,40,'Extractions','Wisdom tooth','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12010,41,'Root Canal','Premolars','Good');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12011,42,'Extractions','Wisdom tooth','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12012,43,'Veneers','Incisors','Need a second sitting');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12013,44,'Root Canal','Premolars','Excellent');
INSERT INTO DentalRecords (PatientID,AppntID,DescriptionOfProcedure,ToothAssociated,ProcedureOutcome) VALUES (12014,45,'Extractions','Wisdom tooth','Good');

raiserror('INSERTION COMPLETED SUCCESSFULLY...',0,1)
GO
