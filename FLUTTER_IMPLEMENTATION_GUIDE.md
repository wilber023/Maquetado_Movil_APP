# 🚀 Guía de Implementación Flutter - Joven Saludable

## 📱 Estructura de Navegación Flutter Recomendada

### 🏗️ Arquitectura Base
```dart
// lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routes/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── presentation/
│   ├── screens/
│   │   ├── onboarding/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── chat/
│   │   ├── community/
│   │   └── profile/
│   ├── widgets/
│   └── providers/
└── domain/
    ├── entities/
    ├── repositories/
    └── usecases/
```

## 🎯 Implementación de Transiciones

### 1. **Slide Transitions (slideR, slideL)**
```dart
class SlideTransition extends PageRouteBuilder {
  final Widget child;
  final bool slideFromRight;
  
  SlideTransition({required this.child, this.slideFromRight = true})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Right
            const end = Offset.zero;
            const curve = Curves.easeOut;
            
            var tween = Tween(begin: slideFromRight ? begin : Offset(-1.0, 0.0), end: end)
                .chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
```

### 2. **Modal Transitions (modalUp, modalDown)**
```dart
class ModalTransition extends PageRouteBuilder {
  final Widget child;
  
  ModalTransition({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;
            
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}
```

### 3. **Fade Transitions**
```dart
class FadeTransition extends PageRouteBuilder {
  final Widget child;
  
  FadeTransition({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}
```

## 🧭 Sistema de Navegación

### Navigation Service
```dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static Future<void> navigateToScreen(String screenId, {TransitionType? transition}) async {
    final route = _getRoute(screenId, transition);
    await navigatorKey.currentState?.push(route);
  }
  
  static void goBack() {
    navigatorKey.currentState?.pop();
  }
  
  static PageRoute _getRoute(String screenId, TransitionType? transition) {
    final screen = _getScreenWidget(screenId);
    
    switch (transition) {
      case TransitionType.slideRight:
        return SlideTransition(child: screen, slideFromRight: true);
      case TransitionType.slideLeft:
        return SlideTransition(child: screen, slideFromRight: false);
      case TransitionType.modalUp:
        return ModalTransition(child: screen);
      case TransitionType.fade:
      default:
        return FadeTransition(child: screen);
    }
  }
}

enum TransitionType { slideRight, slideLeft, modalUp, modalDown, fade }
```

## 📊 Estado Global de la App

### App State Provider
```dart
class AppState extends ChangeNotifier {
  String _currentScreen = 'splash';
  bool _isLoggedIn = false;
  String _userName = '';
  int _notifications = 3;
  bool _modalOpen = false;
  bool _transitionInProgress = false;
  
  // Getters
  String get currentScreen => _currentScreen;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  int get notifications => _notifications;
  bool get modalOpen => _modalOpen;
  bool get transitionInProgress => _transitionInProgress;
  
  // Navigation methods
  void setCurrentScreen(String screen) {
    _currentScreen = screen;
    notifyListeners();
  }
  
  Future<void> login(String username) async {
    _isLoggedIn = true;
    _userName = username;
    notifyListeners();
    
    await NavigationService.navigateToScreen('feed', transition: TransitionType.slideRight);
    showToast('¡Sesión iniciada correctamente!', ToastType.success);
  }
  
  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = '';
    notifyListeners();
    
    await NavigationService.navigateToScreen('login', transition: TransitionType.slideRight);
  }
}
```

## 🏠 Bottom Tab Bar Implementation

### Custom Bottom Navigation
```dart
class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  
  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Stack(
        children: [
          // Tab Items
          Row(
            children: [
              _buildTabItem(0, Icons.home, 'Inicio'),
              _buildTabItem(1, Icons.chat_bubble, 'Coach IA'),
              Expanded(child: SizedBox()), // Space for FAB
              _buildTabItem(2, Icons.groups, 'Comunidad'),
              _buildTabItem(3, Icons.person, 'Perfil'),
            ],
          ),
          // Floating Action Button
          Positioned(
            top: -8,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: FloatingActionButton(
              onPressed: () => _openCreatePost(),
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.add, size: 32),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTabItem(int index, IconData icon, String label) {
    final isActive = widget.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _openCreatePost() {
    NavigationService.navigateToScreen('create_post', transition: TransitionType.modalUp);
  }
}
```

## 🎨 Tema y Estilos

### App Theme
```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xFF7B3FE4),
      scaffoldBackgroundColor: Color(0xFFF7F6F8),
      fontFamily: 'Inter',
      
      colorScheme: ColorScheme.light(
        primary: Color(0xFF7B3FE4),
        secondary: Color(0xFFF5A623),
        background: Color(0xFFF7F6F8),
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Color(0xFF4A4A4A),
        onSurface: Color(0xFF4A4A4A),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF4A4A4A),
        elevation: 0,
        centerTitle: true,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF7B3FE4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF7B3FE4)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
```

## 🔄 Flujos Críticos Implementados

### 1. Registro Completo → Primer Post
```dart
class OnboardingFlow {
  static Future<void> completeRegistrationFlow() async {
    await NavigationService.navigateToScreen('register_step1', transition: TransitionType.slideRight);
    // Usuario completa paso 1
    await NavigationService.navigateToScreen('register_step2', transition: TransitionType.slideRight);
    // Usuario completa paso 2
    await NavigationService.navigateToScreen('feed', transition: TransitionType.slideRight);
    // Usuario crea primer post
    await NavigationService.navigateToScreen('create_post', transition: TransitionType.modalUp);
  }
}
```

### 2. Login → Chat IA
```dart
class AuthFlow {
  static Future<void> loginToChatFlow() async {
    await NavigationService.navigateToScreen('login', transition: TransitionType.slideRight);
    // Usuario hace login
    await NavigationService.navigateToScreen('feed', transition: TransitionType.slideRight);
    // Navegar a Chat IA
    await NavigationService.navigateToScreen('chat_ia', transition: TransitionType.fade);
  }
}
```

## 🧪 Testing de Navegación

### Navigation Tests
```dart
void main() {
  group('Navigation Tests', () {
    testWidgets('Should navigate from splash to welcome after 2 seconds', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Verificar splash screen
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Esperar auto-advance
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Verificar welcome screen
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });
    
    testWidgets('Should navigate through registration flow', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // Tap register button
      await tester.tap(find.text('Registrarme'));
      await tester.pumpAndSettle();
      
      expect(find.byType(RegisterStep1Screen), findsOneWidget);
      
      // Complete step 1
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();
      
      expect(find.byType(RegisterStep2Screen), findsOneWidget);
    });
  });
}
```

## 📝 Checklist de Implementación

### ✅ Fase 1: Setup Base
- [ ] Crear estructura de carpetas
- [ ] Configurar navegación y rutas
- [ ] Implementar transiciones personalizadas
- [ ] Setup provider para estado global
- [ ] Configurar tema de la app

### ✅ Fase 2: Pantallas Core
- [ ] Splash Screen con auto-advance
- [ ] Welcome Screen con navegación
- [ ] Login/Register con validaciones
- [ ] Feed principal con posts
- [ ] Bottom Tab Bar funcional

### ✅ Fase 3: Features Avanzadas
- [ ] Chat IA con mensajes
- [ ] Sistema de posts y likes
- [ ] Perfil de usuario
- [ ] Configuraciones y privacidad
- [ ] Notificaciones

### ✅ Fase 4: Polish y Testing
- [ ] Animaciones y microinteracciones
- [ ] Testing de navegación
- [ ] Performance optimization
- [ ] Accessibility features

## 🚀 Comandos de Inicio Rápido

```bash
# Crear nuevo proyecto Flutter
flutter create joven_saludable
cd joven_saludable

# Agregar dependencias principales
flutter pub add provider
flutter pub add go_router
flutter pub add shared_preferences
flutter pub add http
flutter pub add flutter_svg

# Ejecutar en simulador
flutter run
```

---

Esta guía te permitirá implementar exactamente el mismo comportamiento que ves en el prototipo HTML, pero usando Flutter con todas las mejores prácticas de la plataforma. 🎯