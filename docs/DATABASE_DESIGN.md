# RaceDay Database Design

This document defines the entities, attributes, keys, constraints and relationships planned for the RaceDay relational database. Primary and foreign keys help enforce data integrity and establish relationships between SQL Server tables (Microsoft, 2025a). Relational database relationships are represented through foreign keys that connect dependent and principal records (Microsoft, 2023). The database also uses `UNIQUE`, `CHECK`, `NOT NULL` and `DEFAULT` constraints to control accepted values and prevent invalid or duplicate information (Microsoft, 2025b).

## Entity 1 Users

The `Users` entity stores authentication and role information for organisers and participants.

| Attribute    | Data type     | Key or constraint      | Description                              |
| ------------ | ------------- | ---------------------- | ---------------------------------------- |
| UserId       | INT           | Primary Key            | Uniquely identifies a user.              |
| Email        | NVARCHAR(256) | Required and Unique    | Stores the user’s email address.         |
| PasswordHash | NVARCHAR(500) | Required               | Stores the securely hashed password.     |
| Role         | NVARCHAR(20)  | Required and Check     | Stores Organiser or Participant.         |
| IsActive     | BIT           | Required and Default 1 | Indicates whether the account is active. |
| CreatedAtUtc | DATETIME2     | Required and Default   | Records when the account was created.    |

## Entity 2 UserProfiles

The `UserProfiles` entity stores personal information separately from authentication information.

| Attribute     | Data type    | Key or constraint      | Description                            |
| ------------- | ------------ | ---------------------- | -------------------------------------- |
| UserProfileId | INT          | Primary Key            | Uniquely identifies a profile.         |
| UserId        | INT          | Foreign Key and Unique | Links the profile to one user.         |
| FirstName     | NVARCHAR(80) | Required               | Stores the user’s first name.          |
| LastName      | NVARCHAR(80) | Required               | Stores the user’s surname.             |
| PhoneNumber   | NVARCHAR(20) | Optional and Check     | Stores a South African contact number. |
| DateOfBirth   | DATE         | Optional               | Stores the user’s date of birth.       |

## Entity 3 Events

The `Events` entity stores information about running, walking and cycling events.

| Attribute             | Data type      | Key or constraint           | Description                                      |
| --------------------- | -------------- | --------------------------- | ------------------------------------------------ |
| EventId               | INT            | Primary Key                 | Uniquely identifies an event.                    |
| OrganiserId           | INT            | Foreign Key                 | Links the event to the organiser who created it. |
| Name                  | NVARCHAR(150)  | Required                    | Stores the event name.                           |
| Description           | NVARCHAR(1000) | Optional                    | Describes the event.                             |
| EventType             | NVARCHAR(20)   | Required and Check          | Stores Running, Walking or Cycling.              |
| EventDate             | DATETIME2      | Required                    | Stores the event date and starting time.         |
| Venue                 | NVARCHAR(150)  | Required                    | Stores the event venue.                          |
| City                  | NVARCHAR(100)  | Required                    | Stores the city.                                 |
| Province              | NVARCHAR(50)   | Required                    | Stores the province.                             |
| RegistrationCloseDate | DATETIME2      | Required and Check          | Stores the registration closing date.            |
| MaxParticipants       | INT            | Required and Check          | Stores the maximum number of participants.       |
| Status                | NVARCHAR(20)   | Required, Default and Check | Stores the event status.                         |
| CreatedAtUtc          | DATETIME2      | Required and Default        | Records when the event was created.              |

## Entity 4 Routes

The `Routes` entity stores the route associated with each event.

| Attribute      | Data type     | Key or constraint      | Description                        |
| -------------- | ------------- | ---------------------- | ---------------------------------- |
| RouteId        | INT           | Primary Key            | Uniquely identifies a route.       |
| EventId        | INT           | Foreign Key and Unique | Links the route to one event.      |
| DistanceKm     | DECIMAL(6,2)  | Required and Check     | Stores the distance in kilometres. |
| StartLatitude  | DECIMAL(9,6)  | Optional and Check     | Stores the starting latitude.      |
| StartLongitude | DECIMAL(9,6)  | Optional and Check     | Stores the starting longitude.     |
| EndLatitude    | DECIMAL(9,6)  | Optional and Check     | Stores the finishing latitude.     |
| EndLongitude   | DECIMAL(9,6)  | Optional and Check     | Stores the finishing longitude.    |
| RouteMapUrl    | NVARCHAR(500) | Optional               | Stores a link to the route map.    |

## Entity 5 EventCategories

The `EventCategories` entity stores the entry categories offered for each event.

| Attribute  | Data type     | Key or constraint           | Description                        |
| ---------- | ------------- | --------------------------- | ---------------------------------- |
| CategoryId | INT           | Primary Key                 | Uniquely identifies a category.    |
| EventId    | INT           | Foreign Key                 | Links the category to an event.    |
| Name       | NVARCHAR(100) | Required                    | Stores the category name.          |
| DistanceKm | DECIMAL(6,2)  | Required and Check          | Stores the category distance.      |
| Fee        | DECIMAL(10,2) | Required, Default and Check | Stores the entry fee.              |
| MinimumAge | INT           | Required, Default and Check | Stores the minimum permitted age.  |
| Capacity   | INT           | Required and Check          | Stores the category entry limit.   |
| StartTime  | TIME          | Required                    | Stores the category starting time. |

The combination of `EventId` and `Name` is unique, preventing duplicate category names within the same event.

## Entity 6 Enrolments

The `Enrolments` entity records participants entering event categories.

| Attribute             | Data type     | Key or constraint           | Description                               |
| --------------------- | ------------- | --------------------------- | ----------------------------------------- |
| EnrolmentId           | INT           | Primary Key                 | Uniquely identifies an enrolment.         |
| CategoryId            | INT           | Foreign Key                 | Links the enrolment to an event category. |
| ParticipantId         | INT           | Foreign Key                 | Links the enrolment to a participant.     |
| EnrolledAtUtc         | DATETIME2     | Required and Default        | Records when the participant enrolled.    |
| Status                | NVARCHAR(20)  | Required, Default and Check | Stores the enrolment status.              |
| EmergencyContactName  | NVARCHAR(160) | Required                    | Stores the emergency contact’s name.      |
| EmergencyContactPhone | NVARCHAR(20)  | Required and Check          | Stores the emergency contact number.      |

The combination of `CategoryId` and `ParticipantId` is unique, preventing a participant from entering the same category twice.

## Entity 7 Results

The `Results` entity stores the official performance recorded for an enrolment.

| Attribute         | Data type    | Key or constraint           | Description                                |
| ----------------- | ------------ | --------------------------- | ------------------------------------------ |
| ResultId          | INT          | Primary Key                 | Uniquely identifies a result.              |
| EnrolmentId       | INT          | Foreign Key and Unique      | Links the result to one enrolment.         |
| FinishTimeSeconds | INT          | Optional and Check          | Stores the finishing time in seconds.      |
| OverallPosition   | INT          | Optional and Check          | Stores the overall finishing position.     |
| CategoryPosition  | INT          | Optional and Check          | Stores the category finishing position.    |
| Status            | NVARCHAR(20) | Required, Default and Check | Stores Finished, DNF, DNS or Disqualified. |
| RecordedAtUtc     | DATETIME2    | Required and Default        | Records when the result was captured.      |

## Entity 8 WeatherSnapshots

The `WeatherSnapshots` entity stores weather information collected for an event.

| Attribute           | Data type     | Key or constraint  | Description                                  |
| ------------------- | ------------- | ------------------ | -------------------------------------------- |
| WeatherSnapshotId   | INT           | Primary Key        | Uniquely identifies a weather snapshot.      |
| EventId             | INT           | Foreign Key        | Links the weather information to an event.   |
| ObservedAtUtc       | DATETIME2     | Required           | Records when the weather data was collected. |
| TemperatureC        | DECIMAL(5,2)  | Optional           | Stores the temperature in degrees Celsius.   |
| WindSpeedKph        | DECIMAL(6,2)  | Optional and Check | Stores the wind speed.                       |
| PrecipitationChance | TINYINT       | Optional and Check | Stores the chance of rain from 0 to 100.     |
| Conditions          | NVARCHAR(100) | Optional           | Describes the weather conditions.            |

The combination of `EventId` and `ObservedAtUtc` is unique, preventing duplicate weather observations.

## Database Relationships

| Parent entity   | Relationship       | Child entity     | Explanation                                                |
| --------------- | ------------------ | ---------------- | ---------------------------------------------------------- |
| Users           | One to one         | UserProfiles     | Each user has one profile.                                 |
| Users           | One to many        | Events           | An organiser can create multiple events.                   |
| Users           | One to many        | Enrolments       | A participant can have multiple enrolments.                |
| Events          | One to one         | Routes           | Each event has one route.                                  |
| Events          | One to many        | EventCategories  | Each event contains one or more categories.                |
| Events          | One to many        | WeatherSnapshots | An event may have multiple weather observations.           |
| EventCategories | One to many        | Enrolments       | A category can receive multiple enrolments.                |
| Enrolments      | One to zero or one | Results          | An enrolment may have one official result after the event. |

## Database Business Rules

1. Every user must have a unique email address.
2. A user must have either the Organiser or Participant role.
3. Each user can have only one user profile.
4. Only organisers may create and manage events.
5. Every event must belong to one organiser.
6. An event’s registration closing date must be before its event date.
7. The maximum number of participants must be greater than zero.
8. Each event must have one route.
9. An event must have one or more entry categories.
10. Category distances and capacities must be greater than zero.
11. Category fees cannot be negative.
12. Participants may enrol in multiple events.
13. A participant cannot enrol in the same category more than once.
14. Every enrolment must belong to one participant and one category.
15. An enrolment can have a maximum of one official result.
16. Finishing times and
