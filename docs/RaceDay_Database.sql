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