# RaceDay Database Design

This document defines the entities, attributes, keys and relationships planned for the RaceDay relational database.

## Entity 1: Users

The Users entity stores authentication and role information for organisers and participants.

| Attribute | Data type | Key or constraint | Description |
|---|---|---|---|
| UserId | INT | Primary Key | Uniquely identifies a user. |
| Email | NVARCHAR(256) | Required and Unique | Stores the user's email address. |
| PasswordHash | NVARCHAR(500) | Required | Stores the securely hashed password. |
| Role | NVARCHAR(20) | Required | Identifies the user as an Organiser or Participant. |
| IsActive | BIT | Required, Default 1 | Indicates whether the account is active. |
| CreatedAtUtc | DATETIME2 | Required | Records when the account was created. |

## Entity 2: UserProfiles

The UserProfiles entity stores the personal details associated with each user account.

| Attribute | Data type | Key or constraint | Description |
|---|---|---|---|
| UserProfileId | INT | Primary Key | Uniquely identifies a profile. |
| UserId | INT | Foreign Key and Unique | Links the profile to one Users record. |
| FirstName | NVARCHAR(80) | Required | Stores the user's first name. |
| LastName | NVARCHAR(80) | Required | Stores the user's surname. |
| PhoneNumber | NVARCHAR(20) | Optional | Stores the user's contact number. |
| DateOfBirth | DATE | Optional | Stores the user's date of birth. |

### Users and UserProfiles relationship

One user has one profile, and each profile belongs to one user.

Cardinality:

```text
Users 1 ───── 1 UserProfiles

## Entity 4: Routes

The Routes entity stores the route information associated with an event.

| Attribute | Data type | Key or constraint | Description |
|---|---|---|---|
| RouteId | INT | Primary Key | Uniquely identifies a route. |
| EventId | INT | Foreign Key and Unique | Links the route to one event. |
| DistanceKm | DECIMAL(6,2) | Required | Stores the route distance in kilometres. |
| StartLatitude | DECIMAL(9,6) | Optional | Stores the latitude of the starting location. |
| StartLongitude | DECIMAL(9,6) | Optional | Stores the longitude of the starting location. |
| EndLatitude | DECIMAL(9,6) | Optional | Stores the latitude of the finishing location. |
| EndLongitude | DECIMAL(9,6) | Optional | Stores the longitude of the finishing location. |
| RouteMapUrl | NVARCHAR(500) | Optional | Stores a link to the route map. |

### Events and Routes relationship

Each event has one route, and each route belongs to one event.

Cardinality:

```text
Events 1 ───── 1 Routes

## Entity 6: Enrolments

The Enrolments entity records participants entering specific event categories.

| Attribute | Data type | Key or constraint | Description |
|---|---|---|---|
| EnrolmentId | INT | Primary Key | Uniquely identifies an enrolment. |
| CategoryId | INT | Foreign Key | Links the enrolment to an event category. |
| ParticipantId | INT | Foreign Key | Links the enrolment to a participant user. |
| EnrolledAtUtc | DATETIME2 | Required | Records when the participant enrolled. |
| Status | NVARCHAR(20) | Required | Stores Pending, Confirmed, Cancelled or Disqualified. |
| EmergencyContactName | NVARCHAR(160) | Required | Stores the participant's emergency contact name. |
| EmergencyContactPhone | NVARCHAR(20) | Required | Stores the emergency contact number. |

### EventCategories and Enrolments relationship

One event category can have many enrolments, but each enrolment belongs to one category.

Cardinality:

```text
EventCategories 1 ───── M Enrolments

## Entity 8: WeatherSnapshots

The WeatherSnapshots entity stores weather information collected for an event. Multiple snapshots may be stored as the event date approaches.

| Attribute | Data type | Key or constraint | Description |
|---|---|---|---|
| WeatherSnapshotId | INT | Primary Key | Uniquely identifies a weather snapshot. |
| EventId | INT | Foreign Key | Links the weather information to an event. |
| ObservedAtUtc | DATETIME2 | Required | Records when the weather data was collected. |
| TemperatureC | DECIMAL(5,2) | Optional | Stores the temperature in degrees Celsius. |
| WindSpeedKph | DECIMAL(6,2) | Optional | Stores the wind speed in kilometres per hour. |
| PrecipitationChance | TINYINT | Optional | Stores the chance of rain as a percentage. |
| Conditions | NVARCHAR(100) | Optional | Describes the expected weather conditions. |

### Events and WeatherSnapshots relationship

One event can have many weather snapshots, but every weather snapshot belongs to one event.

Cardinality:

```text
Events 1 ───── M WeatherSnapshots