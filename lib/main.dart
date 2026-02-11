import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/market_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/auto_invest_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/sip_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stock_detail_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/auto_invest_screen.dart';
import 'screens/commodities_screen.dart';
import 'screens/mutual_funds_screen.dart';
import 'screens/sip_screen.dart';
import 'screens/screener_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/challenge_screen.dart';
import 'screens/risk_screen.dart';
import 'screens/learn_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  await NotificationService.init();
  runApp(const PugazhStocksApp());
}

class PugazhStocksApp extends StatelessWidget {
  const PugazhStocksApp({super.key});
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    NotificationService.navigatorKey = navigatorKey;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => AutoInvestProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
        ChangeNotifierProvider(create: (_) => SipProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, tp, _) {
          // Bind the global singleton so AppTheme.bgColor etc. auto-update
          AppTheme.bind(tp);
          final isDark = tp.isDark;
          final baseText = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
          return MaterialApp(            navigatorKey: PugazhStocksApp.navigatorKey,            title: 'Pugazh Stocks',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: isDark ? Brightness.dark : Brightness.light,
              colorScheme: ColorScheme(
                brightness: isDark ? Brightness.dark : Brightness.light,
                primary: tp.accent,
                secondary: tp.secondary,
                surface: tp.card,
                error: AppTheme.red,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: tp.textPri,
                onError: Colors.white,
              ),
              scaffoldBackgroundColor: tp.bg,
              textTheme: GoogleFonts.interTextTheme(baseText),
              useMaterial3: true,
              splashColor: tp.accent.withValues(alpha: 0.08),
              highlightColor: tp.accent.withValues(alpha: 0.05),
              canvasColor: tp.card,
              dialogBackgroundColor: tp.card,
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeScreen(),
              '/stock-detail': (_) => const StockDetailScreen(),
              '/wallet': (_) => const WalletScreen(),
              '/watchlist': (_) => const WatchlistScreen(),
              '/orders': (_) => const OrdersScreen(),
              '/auto-invest': (_) => const AutoInvestScreen(),
              '/commodities': (_) => const CommoditiesScreen(),
              '/mutual-funds': (_) => const MutualFundsScreen(),
              '/sip': (_) => const SipScreen(),
              '/screener': (_) => const ScreenerScreen(),
              '/journal': (_) => const JournalScreen(),
              '/challenge': (_) => const ChallengeScreen(),
              '/risk': (_) => const RiskScreen(),
              '/learn': (_) => const LearnScreen(),
            },
          );
        },
      ),
    );
  }
}
