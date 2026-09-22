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