import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/core/theme.dart';
import 'package:campusflow/core/widgets/ecran_marque.dart';
import 'package:campusflow/features/auth/application/auth_provider.dart';

/// Écran de connexion (route `/login`).
///
/// Une fois connecté, rien à faire ici : le routeur voit la nouvelle
/// session et ouvre la page demandée au départ (ou les échéances).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();

  bool _envoi = false;
  bool _masque = true;
  String? _erreur;

  @override
  void dispose() {
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _connecter() async {
    if (_envoi || !_formKey.currentState!.validate()) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      await ref
          .read(authProvider.notifier)
          .connecter(email: _email.text, motDePasse: _motDePasse.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.message;
        _envoi = false;
      });
      _motDePasse.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final avis = ref.watch(avisConnexionProvider);
    final message = _erreur ?? avis;

    return EcranMarque(
      feuille: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Connexion', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Retrouve tes échéances depuis le serveur du campus.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (message != null) ...[
                _Bandeau(message: message),
                const SizedBox(height: AppSpacing.screen),
              ],
              TextFormField(
                controller: _email,
                enabled: !_envoi,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                decoration: const InputDecoration(
                  labelText: 'Adresse universitaire',
                  hintText: 'prenom.nom@universite.bf',
                  prefixIcon: Icon(Icons.alternate_email_rounded, size: 20),
                ),
                validator: (valeur) {
                  final texte = valeur?.trim() ?? '';
                  if (texte.isEmpty) return 'Adresse requise';
                  if (!texte.contains('@')) return 'Adresse invalide';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _motDePasse,
                enabled: !_envoi,
                obscureText: _masque,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _connecter(),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    tooltip: _masque
                        ? 'Afficher le mot de passe'
                        : 'Masquer le mot de passe',
                    icon: Icon(
                      _masque
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _masque = !_masque),
                  ),
                ),
                validator: (valeur) =>
                    (valeur ?? '').isEmpty ? 'Mot de passe requis' : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _envoi ? null : _connecter,
                child: _envoi
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          semanticsLabel: 'Connexion en cours',
                        ),
                      )
                    : const Text('Se connecter'),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Compte de démonstration : ibrahim.kabore@universite.bf · '
                'campus2026',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Message d'erreur ou d'information au-dessus du formulaire.
class _Bandeau extends StatelessWidget {
  const _Bandeau({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final campus = context.campusColors;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: campus.urgentContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: campus.urgent, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: campus.urgent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
