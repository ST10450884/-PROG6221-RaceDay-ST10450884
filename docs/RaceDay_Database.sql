/*
    RaceDay Event Management System
    Part 1 Database Creation Script
    Database platform: Microsoft SQL Server
*/

USE master;
GO

IF DB_ID(N'RaceDayDB') IS NOT NULL
BEGIN
    ALTER DATABASE RaceDayDB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE RaceDayDB;
END;
GO

CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

/* USERS TABLE */

CREATE TABLE dbo.Users
(
    UserId INT IDENTITY(1,1)
        CONSTRAINT PK_Users PRIMARY KEY,

    Email NVARCHAR(256) NOT NULL
        CONSTRAINT UQ_Users_Email UNIQUE,

    PasswordHash NVARCHAR(500) NOT NULL,

    Role NVARCHAR(20) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Users_IsActive DEFAULT (1),

    CreatedAtUtc DATETIME2(0) NOT NULL
        CONSTRAINT DF_Users_CreatedAtUtc
        DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN (N'Organiser', N'Participant'))
);
GO

/* USER PROFILES TABLE */

CREATE TABLE dbo.UserProfiles
(
    UserProfileId INT IDENTITY(1,1)
        CONSTRAINT PK_UserProfiles PRIMARY KEY,

    UserId INT NOT NULL
        CONSTRAINT UQ_UserProfiles_UserId UNIQUE,

    FirstName NVARCHAR(80) NOT NULL,

    LastName NVARCHAR(80) NOT NULL,

    PhoneNumber NVARCHAR(20) NULL,

    DateOfBirth DATE NULL,

    CONSTRAINT FK_UserProfiles_Users
        FOREIGN KEY (UserId)
        REFERENCES dbo.Users(UserId),

    CONSTRAINT CK_UserProfiles_Phone
        CHECK
        (
            PhoneNumber IS NULL
            OR PhoneNumber LIKE N'+27%'
        )
);
GO

/* =====================================================
   EVENTS TABLE
   Stores running, walking and cycling events.
   ===================================================== */

CREATE TABLE dbo.Events
(
    EventId INT IDENTITY(1,1)
        CONSTRAINT PK_Events PRIMARY KEY,

    OrganiserId INT NOT NULL,

    Name NVARCHAR(150) NOT NULL,

    Description NVARCHAR(1000) NULL,

    EventType NVARCHAR(20) NOT NULL,

    EventDate DATETIME2(0) NOT NULL,

    Venue NVARCHAR(150) NOT NULL,

    City NVARCHAR(100) NOT NULL,

    Province NVARCHAR(50) NOT NULL,

    RegistrationCloseDate DATETIME2(0) NOT NULL,

    MaxParticipants INT NOT NULL,

    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Events_Status DEFAULT (N'Draft'),

    CreatedAtUtc DATETIME2(0) NOT NULL
        CONSTRAINT DF_Events_CreatedAtUtc
        DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT FK_Events_Users
        FOREIGN KEY (OrganiserId)
        REFERENCES dbo.Users(UserId),

    CONSTRAINT CK_Events_Type
        CHECK
        (
            EventType IN
            (
                N'Running',
                N'Walking',
                N'Cycling'
            )
        ),

    CONSTRAINT CK_Events_Status
        CHECK
        (
            Status IN
            (
                N'Draft',
                N'Published',
                N'Completed',
                N'Cancelled'
            )
        ),

    CONSTRAINT CK_Events_MaxParticipants
        CHECK (MaxParticipants > 0),

    CONSTRAINT CK_Events_RegistrationDate
        CHECK (RegistrationCloseDate < EventDate)
);
GO

/* =====================================================
   ROUTES TABLE
   Stores the route associated with each event.
   ===================================================== */

CREATE TABLE dbo.Routes
(
    RouteId INT IDENTITY(1,1)
        CONSTRAINT PK_Routes PRIMARY KEY,

    EventId INT NOT NULL
        CONSTRAINT UQ_Routes_EventId UNIQUE,

    DistanceKm DECIMAL(6,2) NOT NULL,

    StartLatitude DECIMAL(9,6) NULL,

    StartLongitude DECIMAL(9,6) NULL,

    EndLatitude DECIMAL(9,6) NULL,

    EndLongitude DECIMAL(9,6) NULL,

    RouteMapUrl NVARCHAR(500) NULL,

    CONSTRAINT FK_Routes_Events
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
        ON DELETE CASCADE,

    CONSTRAINT CK_Routes_Distance
        CHECK (DistanceKm > 0),

    CONSTRAINT CK_Routes_Latitude
        CHECK
        (
            (StartLatitude IS NULL
                OR StartLatitude BETWEEN -90 AND 90)
            AND
            (EndLatitude IS NULL
                OR EndLatitude BETWEEN -90 AND 90)
        ),

    CONSTRAINT CK_Routes_Longitude
        CHECK
        (
            (StartLongitude IS NULL
                OR StartLongitude BETWEEN -180 AND 180)
            AND
            (EndLongitude IS NULL
                OR EndLongitude BETWEEN -180 AND 180)
        )
);
GO

/* =====================================================
   EVENT CATEGORIES TABLE
   Stores the entry categories offered by each event.
   ===================================================== */

CREATE TABLE dbo.EventCategories
(
    CategoryId INT IDENTITY(1,1)
        CONSTRAINT PK_EventCategories PRIMARY KEY,

    EventId INT NOT NULL,

    Name NVARCHAR(100) NOT NULL,

    DistanceKm DECIMAL(6,2) NOT NULL,

    Fee DECIMAL(10,2) NOT NULL
        CONSTRAINT DF_EventCategories_Fee DEFAULT (0),

    MinimumAge INT NOT NULL
        CONSTRAINT DF_EventCategories_MinimumAge DEFAULT (0),

    Capacity INT NOT NULL,

    StartTime TIME(0) NOT NULL,

    CONSTRAINT FK_EventCategories_Events
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_EventCategories_Event_Name
        UNIQUE (EventId, Name),

    CONSTRAINT CK_EventCategories_Distance
        CHECK (DistanceKm > 0),

    CONSTRAINT CK_EventCategories_Fee
        CHECK (Fee >= 0),

    CONSTRAINT CK_EventCategories_Age
        CHECK (MinimumAge BETWEEN 0 AND 120),

    CONSTRAINT CK_EventCategories_Capacity
        CHECK (Capacity > 0)
);
GO

/* =====================================================
   ENROLMENTS TABLE
   Connects participants to event categories.
   ===================================================== */

CREATE TABLE dbo.Enrolments
(
    EnrolmentId INT IDENTITY(1,1)
        CONSTRAINT PK_Enrolments PRIMARY KEY,

    CategoryId INT NOT NULL,

    ParticipantId INT NOT NULL,

    EnrolledAtUtc DATETIME2(0) NOT NULL
        CONSTRAINT DF_Enrolments_EnrolledAtUtc
        DEFAULT (SYSUTCDATETIME()),

    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Enrolments_Status DEFAULT (N'Pending'),

    EmergencyContactName NVARCHAR(160) NOT NULL,

    EmergencyContactPhone NVARCHAR(20) NOT NULL,

    CONSTRAINT FK_Enrolments_Categories
        FOREIGN KEY (CategoryId)
        REFERENCES dbo.EventCategories(CategoryId),

    CONSTRAINT FK_Enrolments_Users
        FOREIGN KEY (ParticipantId)
        REFERENCES dbo.Users(UserId),

    CONSTRAINT UQ_Enrolments_Category_Participant
        UNIQUE (CategoryId, ParticipantId),

    CONSTRAINT CK_Enrolments_Status
        CHECK
        (
            Status IN
            (
                N'Pending',
                N'Confirmed',
                N'Cancelled',
                N'Disqualified'
            )
        ),

    CONSTRAINT CK_Enrolments_EmergencyPhone
        CHECK (EmergencyContactPhone LIKE N'+27%')
);
GO

/* =====================================================
   RESULTS TABLE
   Stores the official result for an enrolment.
   ===================================================== */

CREATE TABLE dbo.Results
(
    ResultId INT IDENTITY(1,1)
        CONSTRAINT PK_Results PRIMARY KEY,

    EnrolmentId INT NOT NULL
        CONSTRAINT UQ_Results_EnrolmentId UNIQUE,

    FinishTimeSeconds INT NULL,

    OverallPosition INT NULL,

    CategoryPosition INT NULL,

    Status NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Results_Status DEFAULT (N'Finished'),

    RecordedAtUtc DATETIME2(0) NOT NULL
        CONSTRAINT DF_Results_RecordedAtUtc
        DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (EnrolmentId)
        REFERENCES dbo.Enrolments(EnrolmentId),

    CONSTRAINT CK_Results_Time
        CHECK
        (
            FinishTimeSeconds IS NULL
            OR FinishTimeSeconds > 0
        ),

    CONSTRAINT CK_Results_Positions
        CHECK
        (
            (OverallPosition IS NULL OR OverallPosition > 0)
            AND
            (CategoryPosition IS NULL OR CategoryPosition > 0)
        ),

    CONSTRAINT CK_Results_Status
        CHECK
        (
            Status IN
            (
                N'Finished',
                N'DNF',
                N'DNS',
                N'Disqualified'
            )
        )
);
GO

/* =====================================================
   WEATHER SNAPSHOTS TABLE
   Stores weather information collected for each event.
   ===================================================== */

CREATE TABLE dbo.WeatherSnapshots
(
    WeatherSnapshotId INT IDENTITY(1,1)
        CONSTRAINT PK_WeatherSnapshots PRIMARY KEY,

    EventId INT NOT NULL,

    ObservedAtUtc DATETIME2(0) NOT NULL,

    TemperatureC DECIMAL(5,2) NULL,

    WindSpeedKph DECIMAL(6,2) NULL,

    PrecipitationChance TINYINT NULL,

    Conditions NVARCHAR(100) NULL,

    CONSTRAINT FK_WeatherSnapshots_Events
        FOREIGN KEY (EventId)
        REFERENCES dbo.Events(EventId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_WeatherSnapshots_Event_Observed
        UNIQUE (EventId, ObservedAtUtc),

    CONSTRAINT CK_WeatherSnapshots_Precipitation
        CHECK
        (
            PrecipitationChance IS NULL
            OR PrecipitationChance BETWEEN 0 AND 100
        ),

    CONSTRAINT CK_WeatherSnapshots_Wind
        CHECK
        (
            WindSpeedKph IS NULL
            OR WindSpeedKph >= 0
        )
);
GO
CREATE INDEX IX_Events_EventDate
    ON dbo.Events(EventDate);
GO

CREATE INDEX IX_Events_OrganiserId
    ON dbo.Events(OrganiserId);
GO

CREATE INDEX IX_EventCategories_EventId
    ON dbo.EventCategories(EventId);
GO

CREATE INDEX IX_Enrolments_ParticipantId
    ON dbo.Enrolments(ParticipantId);
GO

CREATE INDEX IX_Enrolments_CategoryId
    ON dbo.Enrolments(CategoryId);
GO

CREATE INDEX IX_WeatherSnapshots_EventId_ObservedAtUtc
    ON dbo.WeatherSnapshots(EventId, ObservedAtUtc DESC);
GO

/* =====================================================
   SAMPLE USER DATA
   Two organisers and two participants.
   Password values are demonstration placeholders only.
   Part 2 must generate secure password hashes.
   ===================================================== */

INSERT INTO dbo.Users
(
    Email,
    PasswordHash,
    Role
)
VALUES
(
    N'nomsa@raceday.co.za',
    N'DEMO_HASH_REPLACE_IN_PART2',
    N'Organiser'
),
(
    N'pieter@raceday.co.za',
    N'DEMO_HASH_REPLACE_IN_PART2',
    N'Organiser'
),
(
    N'lerato@example.com',
    N'DEMO_HASH_REPLACE_IN_PART2',
    N'Participant'
),
(
    N'thabo@example.com',
    N'DEMO_HASH_REPLACE_IN_PART2',
    N'Participant'
);
GO

INSERT INTO dbo.UserProfiles
(
    UserId,
    FirstName,
    LastName,
    PhoneNumber,
    DateOfBirth
)
VALUES
(
    1,
    N'Nomsa',
    N'Dlamini',
    N'+27821234567',
    '1988-05-14'
),
(
    2,
    N'Pieter',
    N'Van Wyk',
    N'+27829876543',
    '1982-09-21'
),
(
    3,
    N'Lerato',
    N'Mokoena',
    N'+27711223344',
    '1998-02-11'
),
(
    4,
    N'Thabo',
    N'Nkosi',
    N'+27725556677',
    '1994-07-03'
);
GO
SELECT
    u.UserId,
    u.Email,
    u.Role,
    p.FirstName,
    p.LastName,
    p.PhoneNumber
FROM dbo.Users AS u
INNER JOIN dbo.UserProfiles AS p
    ON p.UserId = u.UserId
ORDER BY u.UserId;
GO

/* =====================================================
   SAMPLE EVENT DATA
   Three South African community events.
   ===================================================== */

INSERT INTO dbo.Events
(
    OrganiserId,
    Name,
    Description,
    EventType,
    EventDate,
    Venue,
    City,
    Province,
    RegistrationCloseDate,
    MaxParticipants,
    Status
)
VALUES
(
    1,
    N'Pretoria Spring Road Race',
    N'A community road-running event through central Pretoria.',
    N'Running',
    '2027-09-18T06:30:00',
    N'Union Buildings',
    N'Pretoria',
    N'Gauteng',
    '2027-09-11T23:59:59',
    1200,
    N'Published'
),
(
    1,
    N'Soweto Family Walk',
    N'A community walking event suitable for families.',
    N'Walking',
    '2027-10-09T07:00:00',
    N'Orlando Stadium',
    N'Soweto',
    N'Gauteng',
    '2027-10-02T23:59:59',
    800,
    N'Published'
),
(
    2,
    N'Cape Peninsula Cycle Challenge',
    N'A scenic road-cycling event around the Cape Peninsula.',
    N'Cycling',
    '2027-11-14T05:45:00',
    N'Green Point Park',
    N'Cape Town',
    N'Western Cape',
    '2027-11-01T23:59:59',
    1500,
    N'Published'
);
GO
INSERT INTO dbo.Routes
(
    EventId,
    DistanceKm,
    StartLatitude,
    StartLongitude,
    EndLatitude,
    EndLongitude,
    RouteMapUrl
)
VALUES
(
    1,
    10.00,
    -25.740300,
    28.212100,
    -25.740300,
    28.212100,
    N'https://example.org/routes/pretoria-race'
),
(
    2,
    5.00,
    -26.231100,
    27.922800,
    -26.231100,
    27.922800,
    N'https://example.org/routes/soweto-walk'
),
(
    3,
    109.00,
    -33.906800,
    18.411300,
    -33.906800,
    18.411300,
    N'https://example.org/routes/cape-cycle'
);
GO
INSERT INTO dbo.EventCategories
(
    EventId,
    Name,
    DistanceKm,
    Fee,
    MinimumAge,
    Capacity,
    StartTime
)
VALUES
(
    1,
    N'Open 10K',
    10.00,
    180.00,
    16,
    900,
    '06:30:00'
),
(
    1,
    N'Junior 5K',
    5.00,
    90.00,
    10,
    300,
    '07:00:00'
),
(
    2,
    N'Family 5K',
    5.00,
    75.00,
    0,
    600,
    '07:00:00'
),
(
    2,
    N'Community 10K Walk',
    10.00,
    120.00,
    12,
    200,
    '06:45:00'
),
(
    3,
    N'Open 109K',
    109.00,
    650.00,
    18,
    1200,
    '05:45:00'
),
(
    3,
    N'Relay Team',
    109.00,
    900.00,
    16,
    300,
    '06:00:00'
);
GO
SELECT
    e.EventId,
    e.Name AS EventName,
    e.EventType,
    r.DistanceKm AS RouteDistance,
    c.Name AS CategoryName,
    c.DistanceKm AS CategoryDistance,
    c.Fee
FROM dbo.Events AS e
INNER JOIN dbo.Routes AS r
    ON r.EventId = e.EventId
INNER JOIN dbo.EventCategories AS c
    ON c.EventId = e.EventId
ORDER BY e.EventId, c.CategoryId;
GO