# 🚗 Fuel Calculator

A comprehensive Flutter application for tracking fuel consumption, vehicle expenses, and generating detailed statistics for your vehicles.

## 📱 Features

### 🚙 Vehicle Management
- Add multiple vehicles with detailed information
- Track vehicle specifications (make, model, year, engine)
- Manage vehicle aliases and custom naming

### ⛽ Fuel Tracking
- Record fuel refills with automatic consumption calculations
- **Full and Partial refueling support** with smart consumption calculation
  - Partial refuels display consumption from previous full tank
  - Full refuels aggregate fuel from preceding partial refuels
- GPS location tracking for refueling stations
- Automatic distance calculation from odometer readings
- Price per liter tracking and cost analysis
- Color-coded visualization (orange/red for full, grey for partial)

### 💰 Expense Management
- Track various vehicle-related expenses (maintenance, repairs, insurance, etc.)
- Categorize expenses with custom categories
- Comprehensive cost tracking beyond fuel

### 📊 Advanced Statistics
- **Flexible range selection**:
  - Last 5 refuelings
  - Last 10 refuelings
  - Current year
  - Previous year
  - All records
- **Persistent settings**: Range selection saved across app sessions
- Detailed fuel consumption analytics
- Cost analysis including fuel and expenses
- Visual bar charts for volume and consumption trends
- Cost per 100km calculations (fuel + expenses)
- Synchronized statistics across all screens

### 💾 Backup & Data Management
- **JSON Backup**: Universal format, works on all platforms
- **SQLite Backup**: Original database file export/import (desktop/mobile only)
- Complete data export/import functionality
- Cross-platform data migration support

## 🛠 Technical Features

### Multi-Platform Support
- **Web**: Runs in any modern web browser
- **Desktop**: Windows, macOS, Linux support
- **Mobile**: Android and iOS ready

### Database Architecture
- **SQLite**: Native database for desktop and mobile platforms (fuel.sqlite)
- **SharedPreferences**: Web-compatible data storage
- Automatic platform detection and appropriate storage selection
- Type-safe RefuelType enum (full/partial) for refueling classification

### GPS Integration
- Automatic location capture during refueling (mobile platforms)
- Location-based refueling history
- Permission handling for location services

### Modern UI/UX
- Material Design 3 implementation
- Responsive design for all screen sizes
- Polish locale formatting for currency and numbers
- Interactive charts and visualizations

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- For mobile development: Android Studio / Xcode
- For web development: Chrome browser

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/mikspec/fuelcalc.git
   cd fuelcalc
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   
   For web:
   ```bash
   flutter run -d chrome
   ```
   
   For desktop:
   ```bash
   flutter run -d windows  # or macos/linux
   ```
   
   For mobile:
   ```bash
   flutter run  # with connected device/emulator
   ```

### Building for Production

**Web Build:**
```bash
flutter build web
```

**Desktop Build:**
```bash
flutter build windows  # or macos/linux
```

**Mobile Build:**
```bash
flutter build apk      # Android
flutter build ios      # iOS
```

## 📦 Dependencies

### Core Dependencies
- `flutter`: Framework
- `sqflite_common_ffi`: SQLite database for native platforms
- `shared_preferences`: Web storage and preferences
- `intl`: Internationalization and Polish locale formatting
- `provider`: State management for settings

### UI & Visualization
- `fl_chart`: Interactive charts and graphs
- `file_picker`: File selection for backup functionality

### Location Services
- `geolocator`: GPS location tracking
- `permission_handler`: Location permissions management

### Development
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality and linting

## 📱 Platform-Specific Features

### Web Platform
- Uses SharedPreferences for data storage
- JSON backup/restore functionality
- No GPS tracking (web limitation)
- Full statistics and chart support

### Desktop/Mobile Platforms
- Full SQLite database functionality
- GPS location tracking for refueling
- Both JSON and SQLite backup options
- Complete feature set available

## 🗃 Database Schema

### Cars Table (`car_host`)
- Vehicle information and specifications
- Dynamic table creation for each vehicle's fuel records
- Expense tracking table references

### Fuel Records (per vehicle)
- Refueling data with consumption calculations
- **Refuel type classification**: Full tank vs. Partial refueling
- **Smart consumption logic**:
  - Partial refuels inherit consumption from previous full tank
  - Full refuels aggregate preceding partial refuels for accurate calculation
- GPS coordinates and location tracking
- Price and volume information
- Chronological ordering for accurate statistics

### Expenses (per vehicle)
- Categorized expense tracking
- Cost and description details
- Date-based expense history

## 🔧 Configuration

### Application Settings
- **Statistics Range**: Configurable via settings (persisted using SharedPreferences)
- Default range: Last 10 refuelings
- Available options: 5, 10, current year, previous year, or all records
- Settings automatically sync across Car Details and Statistics screens

### Location Services
Add the following permissions for GPS functionality:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track refueling locations.</string>
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- fl_chart contributors for excellent charting capabilities
- SQLite for robust database functionality
- The open-source community for various plugins and tools

## 🐛 Known Issues & Limitations

- GPS tracking only available on mobile platforms
- SQLite backup/restore not available on web platform
- File picker limitations on some web browsers
- Location permission required for GPS features

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/mikspec/fuelcalc/issues) page
2. Create a new issue with detailed description
3. Include platform information and error logs

---

**Made with ❤️ using Flutter**
