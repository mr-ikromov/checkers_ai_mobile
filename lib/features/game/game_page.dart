library;

import 'package:flutter/material.dart';

import '../../core/ai/ai_service.dart';
import '../../data/settings_store.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/common.dart';
import 'game_controller.dart';
import 'widgets/board_view.dart';
import 'widgets/stats_panel.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    required this.ai,
    required this.settings,
    required this.humanSide,
    super.key,
  });

  final AiService ai;
  final SettingsStore settings;
  final int humanSide;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final GameController _controller;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      searchMove: widget.ai.search,
      settings: widget.settings,
    )
      ..addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.newGame(humanSide: widget.humanSide);
    });
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.error != null) {
      final l10n = L10n.of(context);
      final message =
          _controller.error == 'illegal' ? l10n.errorIllegalMove : l10n.errorAi;
      _controller.clearError();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
    if (_controller.hasUnseenResult && !_dialogOpen) {
      _dialogOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showResult());
    }
  }

  Future<void> _showResult() async {
    final winner = _controller.winner;
    if (winner == null || !mounted) return;
    _controller.acknowledgeResult();
    final l10n = L10n.of(context);
    final title = switch (winner) {
      0 => l10n.resultDraw,
      _ when winner == _controller.humanSide => l10n.resultWin,
      _ => l10n.resultLoss,
    };

    final again = await AppDialog.show(
      context,
      title: title,
      dismissLabel: l10n.backToMenu,
      confirmLabel: l10n.playAgain,
      barrierDismissible: false,
    );

    if (!mounted) return;
    _dialogOpen = false;
    if (again) {
      await _controller.newGame();
    } else if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _confirmNewGame() async {
    final l10n = L10n.of(context);
    if (_controller.phase == GamePhase.finished || _controller.ply == 0) {
      await _controller.newGame();
      return;
    }
    final confirmed = await AppDialog.show(
      context,
      title: l10n.newGame,
      dismissLabel: l10n.cancel,
      confirmLabel: l10n.newGame,
    );
    if (confirmed && mounted) await _controller.newGame();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.appTitle,
            style: AppText.title.copyWith(fontSize: 19),
          ),
          systemOverlayStyle: systemOverlayFor(context.palette),
          actions: [
            IconButton(
              tooltip: l10n.newGame,
              onPressed: _confirmNewGame,
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
        body: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: BoardView(controller: _controller),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  StatsPanel(readout: _controller.readout),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
