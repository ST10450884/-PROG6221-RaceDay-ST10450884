# RaceDay Entity Relationship Diagram

```mermaid
erDiagram
    USERS {
        INT UserId PK
        NVARCHAR Email UK
        NVARCHAR PasswordHash
        NVARCHAR Role
        BIT IsActive
        DATETIME2 CreatedAtUtc
    }

    USER_PROFILES {
        INT UserProfileId PK
        INT UserId FK,UK
        NVARCHAR FirstName
        NVARCHAR LastName
        NVARCHAR PhoneNumber
        DATE DateOfBirth
    }

    EVENTS {
        INT EventId PK
        INT OrganiserId FK
        NVARCHAR Name
        NVARCHAR Description
        NVARCHAR EventType
        DATETIME2 EventDate
        NVARCHAR Venue
        NVARCHAR City
        NVARCHAR Province
        DATETIME2 RegistrationCloseDate
        INT MaxParticipants
        NVARCHAR Status
        DATETIME2 CreatedAtUtc
    }

    ROUTES {
        INT RouteId PK
        INT EventId FK,UK
        DECIMAL DistanceKm
        DECIMAL StartLatitude
        DECIMAL StartLongitude
        DECIMAL EndLatitude
        DECIMAL EndLongitude
        NVARCHAR RouteMapUrl
    }

    EVENT_CATEGORIES {
        INT CategoryId PK
        INT EventId FK
        NVARCHAR Name
        DECIMAL DistanceKm
        DECIMAL Fee
        INT MinimumAge
        INT Capacity
        TIME StartTime
    }

    ENROLMENTS {
        INT EnrolmentId PK
        INT CategoryId FK
        INT ParticipantId FK
        DATETIME2 EnrolledAtUtc
        NVARCHAR Status
        NVARCHAR EmergencyContactName
        NVARCHAR EmergencyContactPhone
    }

    RESULTS {
        INT ResultId PK
        INT EnrolmentId FK,UK
        INT FinishTimeSeconds
        INT OverallPosition
        INT CategoryPosition
        NVARCHAR Status
        DATETIME2 RecordedAtUtc
    }

    WEATHER_SNAPSHOTS {
        INT WeatherSnapshotId PK
        INT EventId FK
        DATETIME2 ObservedAtUtc
        DECIMAL TemperatureC
        DECIMAL WindSpeedKph
        TINYINT PrecipitationChance
        NVARCHAR Conditions
    }

USERS ||--|| USER_PROFILES : has
USERS ||--o{ EVENTS : organises
USERS ||--o{ ENROLMENTS : enters
EVENTS ||--|| ROUTES : has
EVENTS ||--|{ EVENT_CATEGORIES : contains
EVENTS ||--o{ WEATHER_SNAPSHOTS : receives
EVENT_CATEGORIES ||--o{ ENROLMENTS : receives
ENROLMENTS ||--o| RESULTS : produces
```

## Relationship Summary

- One user has one user profile.
- One organiser can create many events.
- One participant can have many enrolments.
- One event has one route.
- One event contains one or more categories.
- One event can have multiple weather snapshots.
- One category can receive many enrolments.
- One enrolment can have zero or one result.