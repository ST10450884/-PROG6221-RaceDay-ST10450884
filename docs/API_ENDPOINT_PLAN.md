# RaceDay API Endpoint Plan

This document defines the RESTful API endpoints planned for the RaceDay system.

All routes begin with `/api` and use JSON for request and response bodies.

## Role Definitions

- **Public:** The endpoint can be accessed without logging in.
- **Authenticated:** Any logged-in organiser or participant may access the endpoint.
- **Organiser:** Only an authenticated organiser may access the endpoint.
- **Participant:** Only an authenticated participant may access the endpoint.

## Authentication Endpoints

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| POST | `/api/auth/register` | Creates a new participant account and user profile. | Public | `{ email, password, firstName, lastName, phoneNumber, dateOfBirth }` | `201 Created` with the created user summary. `400 Bad Request` for invalid information. `409 Conflict` when the email already exists. |
| POST | `/api/auth/login` | Validates the user's credentials and provides an authentication token. | Public | `{ email, password }` | `200 OK` with the token, user ID and role. `400 Bad Request` for missing information. `401 Unauthorized` for invalid credentials. |

## User Profile Endpoints

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| GET | `/api/profile` | Returns the account and profile of the currently logged-in user. | Authenticated | None | `200 OK` with the user's profile. `401 Unauthorized` when a valid token is not supplied. `404 Not Found` when the profile does not exist. |
| PUT | `/api/profile` | Updates the profile belonging to the currently logged-in user. | Authenticated | `{ firstName, lastName, phoneNumber, dateOfBirth }` | `200 OK` with the updated profile. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. |

## Event Endpoints

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| GET | `/api/events` | Returns a list of upcoming published events. Optional query parameters may filter events by type, province, date or search text. | Public | None | `200 OK` with a collection of event summaries. |
| GET | `/api/events/{eventId}` | Returns the details of a specific event, including its route and available categories. | Public | None | `200 OK` with the event details. `404 Not Found` when the event does not exist. |
| POST | `/api/events` | Creates a new event owned by the currently logged-in organiser. | Organiser | `{ name, description, eventType, eventDate, venue, city, province, registrationCloseDate, maxParticipants, status }` | `201 Created` with the created event. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the user is not an organiser. |
| PUT | `/api/events/{eventId}` | Updates an event belonging to the currently logged-in organiser. | Organiser | `{ name, description, eventType, eventDate, venue, city, province, registrationCloseDate, maxParticipants, status }` | `200 OK` with the updated event. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the event does not exist. |
| DELETE | `/api/events/{eventId}` | Deletes an event belonging to the currently logged-in organiser when no protected enrolments or results prevent deletion. | Organiser | None | `204 No Content` after deletion. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the event does not exist. `409 Conflict` when related records prevent deletion. |
| GET | `/api/organiser/events` | Returns all events created by the currently logged-in organiser, including draft and completed events. | Organiser | None | `200 OK` with the organiser's events. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the user is not an organiser. |

## Event Category Endpoints

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| GET | `/api/events/{eventId}/categories` | Returns all entry categories available for a specific event. | Public | None | `200 OK` with the event categories. `404 Not Found` when the event does not exist. |
| GET | `/api/events/{eventId}/categories/{categoryId}` | Returns the details of one category belonging to an event. | Public | None | `200 OK` with the category. `404 Not Found` when the event or category does not exist. |
| POST | `/api/events/{eventId}/categories` | Adds a new category to an event owned by the logged-in organiser. | Organiser | `{ name, distanceKm, fee, minimumAge, capacity, startTime }` | `201 Created` with the new category. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the event does not exist. `409 Conflict` when the category name already exists for the event. |
| PUT | `/api/events/{eventId}/categories/{categoryId}` | Updates a category belonging to an event owned by the logged-in organiser. | Organiser | `{ name, distanceKm, fee, minimumAge, capacity, startTime }` | `200 OK` with the updated category. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the event or category does not exist. |
| DELETE | `/api/events/{eventId}/categories/{categoryId}` | Deletes an event category when it has no protected enrolments or results. | Organiser | None | `204 No Content` after deletion. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the event or category does not exist. `409 Conflict` when existing enrolments prevent deletion. |

## Enrolment Endpoints

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| POST | `/api/events/{eventId}/categories/{categoryId}/enrolments` | Enrols the logged-in participant in a selected event category. | Participant | `{ emergencyContactName, emergencyContactPhone }` | `201 Created` with the enrolment. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the user is not a participant. `404 Not Found` when the event or category does not exist. `409 Conflict` when registration is closed, the category is full or the participant is already enrolled. |
| GET | `/api/enrolments/me` | Returns all enrolments belonging to the logged-in participant. | Participant | None | `200 OK` with the participant's enrolments. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the user is not a participant. |
| GET | `/api/enrolments/me/{enrolmentId}` | Returns one enrolment belonging to the logged-in participant. | Participant | None | `200 OK` with the enrolment details. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the enrolment belongs to another participant. `404 Not Found` when the enrolment does not exist. |
| DELETE | `/api/enrolments/me/{enrolmentId}` | Cancels an enrolment belonging to the logged-in participant before the cancellation deadline. | Participant | None | `204 No Content` after cancellation. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the enrolment belongs to another participant. `404 Not Found` when the enrolment does not exist. `409 Conflict` when cancellation is no longer allowed. |
| GET | `/api/events/{eventId}/enrolments` | Returns all participant enrolments for an event owned by the logged-in organiser. | Organiser | None | `200 OK` with the event enrolments. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the event does not exist. |
| PUT | `/api/enrolments/{enrolmentId}/status` | Allows the organiser to confirm, cancel or disqualify an enrolment for an event they own. | Organiser | `{ status }` | `200 OK` with the updated enrolment. `400 Bad Request` for an invalid status. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the enrolment does not exist. |

## Result Endpoints

| HTTP method | Route | Description | Role required | Request body | Expected response |
|---|---|---|---|---|---|
| POST | `/api/enrolments/{enrolmentId}/result` | Captures an official result for a participant enrolment in an event owned by the logged-in organiser. | Organiser | `{ finishTimeSeconds, overallPosition, categoryPosition, status }` | `201 Created` with the recorded result. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the enrolment does not exist. `409 Conflict` when a result already exists. |
| PUT | `/api/enrolments/{enrolmentId}/result` | Updates an existing result for an enrolment in an event owned by the logged-in organiser. | Organiser | `{ finishTimeSeconds, overallPosition, categoryPosition, status }` | `200 OK` with the updated result. `400 Bad Request` for invalid information. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the organiser does not own the event. `404 Not Found` when the enrolment or result does not exist. |
| GET | `/api/events/{eventId}/results` | Returns the published results for a specific event. | Public | None | `200 OK` with the event results. `404 Not Found` when the event does not exist. |
| GET | `/api/results/me` | Returns the personal result history of the logged-in participant. | Participant | None | `200 OK` with the participant's results. `401 Unauthorized` when the user is not logged in. `403 Forbidden` when the user is not a participant. |