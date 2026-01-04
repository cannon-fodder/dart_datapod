# datapod_generator

The code generation engine for the Datapod ORM. This package provides the `build_runner` builders that transform your annotated classes into fully functional database implementations.

## ✨ Features

- **Entity Generation**: Generates managed entity implementations with lazy loading support.
- **Repository Generation**: Implements repository interfaces based on method naming conventions.
- **Initializer Generation**: Discovers all entities, repositories, and plugins to generate `datapod_init.dart`.
- **Plugin Discovery**: Automatically detects local plugins annotated with `@DatapodPluginDef`.

## 📖 Usage

Add this package to your `dev_dependencies`. The generator will automatically detect your entities and repositories.

```bash
# Generate the boilerplate (datapod_init.dart) and implementations
dart run build_runner build
```

This will generate a `datapod_init.dart` file in your `lib` folder, which you use to bootstrap the ORM.

For full documentation, see the [root README](https://github.com/cannon-fodder/dart_datapod/blob/main/README.md).
