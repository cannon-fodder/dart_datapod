# datapod_api

The core API for the Datapod ORM. This package contains the annotations and base interfaces required to define entities and repositories.

## ✨ Features

- **Annotations**:
    - **Modeling**: `@Entity`, `@Column`, `@Id`
    - **Relationships**: `@OneToOne`, `@OneToMany`, `@ManyToOne`, `@ManyToMany`, `@FetchJoin`
    - **Constraints & Indexing**: `@Unique`, `@Index`
    - **Auditing**: `@CreatedAt`, `@UpdatedAt`
    - **Type Conversion**: `@Convert`
- **Base Interfaces**: `BaseRepository`, `DatapodDatabase`, `DatabaseConnection`, `ManagedEntity`.
- **Relationship Support**: Definitions for `FetchType` and `CascadeType`.
- **Query Utilities**: `Pageable`, `Sort`, `Direction`, `Page`.

## 📖 Usage

This package is intended to be used as a dependency in your application code where you define your data models.

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
