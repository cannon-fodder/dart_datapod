# Datapod Flutter Sample

A Flutter sample application demonstrating how to use the Datapod ORM with Flutter.

## ✨ Features

- **Datapod Integration**: Shows how to initialize Datapod with asset-based configuration.
- **PostgreSQL Connectivity**: Demonstrates connecting to a local PostgreSQL database (using `datapod_postgres`).
- **CRUD Operations**: Basic UI for creating, reading, updating, and deleting Todo items.
- **Repository Pattern**: Uses generated repositories (`TodoRepository`) for data access.

## 🛠️ Setup

1. **Start Database**: Ensure you have a PostgreSQL database running. You can use the `docker-compose.yaml` from `datapod_test` or your own setup.
   - Host: `localhost`
   - Port: `5432`
   - User: `postgres`
   - Password: `password`
   - Database: `sample_db`

   *(Note: Adjust `assets/connections.yaml` if your config differs)*

2. **Run the App**:

```bash
flutter pub get
flutter run
```

The application will automatically create the `todo` table if it doesn't exist.
