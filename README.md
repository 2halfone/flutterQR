# QR Code Customizer

This Flutter application allows users to create and customize QR codes easily. Users can enter a URL, select styles, upload images, and download their personalized QR codes.

## Features

- **URL Input**: Enter the URL you want to encode in the QR code.
- **Customization Options**: Choose from various styles, colors, and frames to personalize your QR code.
- **Image Upload**: Upload a logo or image to be included in the QR code.
- **Preview**: View the generated QR code in real-time as you customize it.
- **Download**: Save the generated QR code as an image file.

## Project Structure

```
qr_code_customizer
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── lib/                      # Main application code
│   ├── main.dart             # Entry point of the application
│   ├── screens/              # Contains screen widgets
│   │   ├── home_screen.dart   # Home screen for QR code customization
│   │   └── preview_screen.dart # Screen to preview the generated QR code
│   ├── widgets/              # Reusable widgets
│   │   ├── custom_dropdown.dart # Dropdown menu for selecting options
│   │   ├── color_picker.dart  # Color picker for selecting colors
│   │   └── frame_selector.dart # Selector for frame styles
│   ├── models/               # Data models
│   │   ├── qr_settings.dart   # Holds QR code settings
│   │   └── template.dart      # Represents QR code templates
│   ├── utils/                # Utility functions and constants
│   │   ├── constants.dart     # Constant values used in the app
│   │   └── qr_generator.dart  # Functions for generating QR codes
│   └── services/             # Services for the application
│       └── image_saver.dart   # Functions for saving images
├── assets/                   # Asset files
│   ├── backgrounds/          # Background images for QR codes
│   └── frames/               # Frame images for QR codes
├── pubspec.yaml              # Flutter project configuration
└── README.md                 # Project documentation
```

## Setup Instructions

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd qr_code_customizer
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Run the application**:
   ```
   flutter run
   ```

## Usage

- Open the app and navigate to the home screen.
- Enter the desired URL in the input field.
- Customize your QR code by selecting styles, colors, and uploading images.
- Preview your QR code and download it when you're satisfied with the design.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.