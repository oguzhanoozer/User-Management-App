# User-Management-App

Modern SwiftUI-based user management application. This app can perform user listing, adding, editing, and deletion operations.

## 🚀 Running the Application

### Requirements
- Xcode 15.0 or higher
- iOS 18.5 or higher
- macOS 14.0 or higher

### Installation Steps

1. **Clone the project:**
```bash
git clone <repository-url>
cd "User Management App"
```

2. **Open the project in Xcode:**
```bash
open "User Management App.xcodeproj"
```

3. **Install dependencies:**
   - Xcode will automatically install Swift Package Manager dependencies
   - Alamofire library will be downloaded automatically

4. **Run the application:**
   - Select "User Management App" scheme in Xcode
   - Choose iOS Simulator as target device
   - Press `Cmd + R` to run the application

## 🏗️ Architecture and Technologies

### Architectural Pattern
- **MVVM (Model-View-ViewModel)**: The app uses MVVM architectural pattern
- **Protocol-Oriented Programming**: Utilizes Swift's powerful protocol features
- **Dependency Injection**: Provides loose coupling between services and ViewModels

### Technologies
- **SwiftUI**: Modern declarative UI framework
- **Combine**: For reactive programming
- **Async/Await**: Modern asynchronous programming
- **Alamofire**: HTTP networking library
- **JSONPlaceholder API**: Mock backend service

### Project Structure
```
User Management App/
├── Core/
│   ├── Network/
│   │   ├── APIConfiguration.swift
│   │   ├── Models/
│   │   └── Services/
│   ├── Theme/
│   │   ├── Colors.swift
│   │   ├── Layout.swift
│   │   ├── Spacing.swift
│   │   ├── Strings.swift
│   │   ├── Theme.swift
│   │   └── Typography.swift
│   └── Utils/
│       └── Logger.swift
├── Models/
│   └── User/
├── ViewModels/
├── Views/
│   └── Components/
└── Assets.xcassets/
```

## 📚 External Libraries Used

### Alamofire (5.10.2)
- **Purpose**: HTTP networking operations
- **Features**:
  - RESTful API calls
  - JSON serialization/deserialization
  - Error handling
  - Request/Response validation

### Swift Package Manager
- **Purpose**: Dependency management
- **Configuration**: Defined in `Package.resolved` file

## 🔧 Features

### User Management
- ✅ User list viewing
- ✅ User details viewing
- ✅ Adding new users
- ✅ Editing user information
- ✅ Deleting users
- ✅ Pagination support
- ✅ Pull-to-refresh functionality

### UI/UX Features
- ✅ Modern SwiftUI design
- ✅ Responsive layout
- ✅ Loading states
- ✅ Error handling
- ✅ Empty states
- ✅ Accessibility support

### Network Features
- ✅ RESTful API integration
- ✅ Retry mechanism
- ✅ Offline/Online state management
- ✅ Request/Response logging

## 📝 Logging System

The app includes a comprehensive logging system:

### Log Levels
- `debug`: Debug information during development
- `info`: General information messages
- `warning`: Warning conditions
- `error`: Error conditions
- `critical`: Critical system errors

### Log Categories
- `network`: Network operations
- `ui`: User interface events
- `viewModel`: ViewModel state changes
- `userAction`: User interactions
- `api`: API calls and responses
- `dataFlow`: Data flow operations
- `error`: Error handling
- `lifecycle`: Component lifecycle
- `performance`: Performance metrics

### Usage Examples
```swift
// Simple logging
Logger.info("User list loaded")

// Logging with category
Logger.error("API error", category: .api)

// Special methods
Logger.networkRequest(method: "GET", url: "https://api.example.com/users")
Logger.userAction("User added", details: "ID: 123")
```

## 🎨 Theme System

The app uses a consistent theme system:

### Colors
- `primaryBlue`: Primary blue color
- `backgroundPrimary`: Primary background color
- `textPrimary`: Primary text color
- `errorRed`: Error color

### Typography
- `cardTitleStyle`: Card title style
- `cardSubtitleStyle`: Card subtitle style
- `bodyStyle`: Main text style

### Layout
- `screenPadding`: Screen edge margins
- `cardContainer`: Card container style
- `avatarSize`: Avatar sizes

## 🔄 API Integration

### Endpoints
- `GET /users`: User list
- `GET /users/{id}`: User details
- `POST /users`: Add new user
- `PUT /users/{id}`: Update user
- `DELETE /users/{id}`: Delete user

### Error Handling
- Network errors
- Server errors
- Validation errors
- Timeout errors

## 🧪 Testing

### Unit Tests
- ViewModel tests
- Service tests
- Model tests

### UI Tests
- User interaction tests
- Navigation tests
- Form validation tests

## 📱 Supported Devices

- iPhone (iOS 18.5+)
- iPad (iOS 18.5+)
- iOS Simulator

## 🔧 Development Notes

### Coding Standards
- Swift Style Guide compliant
- MVVM pattern usage
- Protocol-oriented programming
- Modern Swift features (async/await, Combine)

### Performance Optimizations
- Lazy loading
- Image caching
- Memory management
- Network request optimization

### Security
- HTTPS usage
- Input validation
- Error handling
- Secure data storage

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## 📞 Contact

- **Developer**: Oğuzhan ÖZER
- **Email**: oguzoozer@gmail.com
- **Project Link**: https://github.com/oguzhanoozer/User-Management-App

---

**Note**: This application is created for development purposes and uses JSONPlaceholder API. For production use, necessary security measures should be taken. 
