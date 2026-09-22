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