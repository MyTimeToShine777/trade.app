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
    systemNavigationBarColor: AppTheme.bgColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await NotificationService.init();
  runApp(const PugazhStocksApp());
}

class PugazhStocksApp extends StatelessWidget {
  const PugazhStocksApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: MaterialApp(
        title: 'Pugazh Stocks',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: AppTheme.colorScheme,
          scaffoldBackgroundColor: AppTheme.bgColor,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
          splashColor: AppTheme.accent.withValues(alpha: 0.08),
          highlightColor: AppTheme.accent.withValues(alpha: 0.05),
          canvasColor: AppTheme.cardColor,
          dialogBackgroundColor: AppTheme.cardColor,
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
      ),
    );
  }
}
