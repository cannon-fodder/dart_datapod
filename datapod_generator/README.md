# datapod_generator

The code generation engine for the Datapod ORM. This package provides the `build_runner` builders that transform your annotated classes into fully functional database implementations.

## ✨ Features

- **Entity Generation**: Generates managed entity implementations with lazy loading support.
- **Repository Generation**: Implements repository interfaces based on method naming conventions.
- **Initializer Generation**: Discovers all entities, repositories, and plugins to generate `datapod_init.dart`.
- **Plugin Discovery**: Automatically detects local plugins annotated with `@DatapodPluginDef`.

## 📖 Usage

Add this package to your `dev_dependencies` and run the build command:

```bash
dart run build_runner build
```

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
