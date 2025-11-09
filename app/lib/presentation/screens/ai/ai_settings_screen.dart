import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/ai_message_entity.dart';
import '../../providers/ai_assistant_provider.dart';

/// Screen for configuring AI assistant settings and API keys
class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({super.key});

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  final _geminiController = TextEditingController();
  final _claudeController = TextEditingController();
  bool _geminiObscure = true;
  bool _claudeObscure = true;

  @override
  void dispose() {
    _geminiController.dispose();
    _claudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Configurar Assistente IA',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer<AIAssistantProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF5A67D8).withOpacity(0.2),
                            const Color(0xFF6B46C1).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF5A67D8).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF5A67D8), Color(0xFF6B46C1)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Sobre as APIs de IA',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Para usar o assistente IA, você precisa configurar uma chave de API do Google Gemini ou Anthropic Claude. Suas chaves são armazenadas de forma segura no dispositivo.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gemini section
                    _buildProviderSection(
                      context: context,
                      provider: provider,
                      aiProvider: AIProvider.gemini,
                      controller: _geminiController,
                      obscure: _geminiObscure,
                      onObscureToggle: () {
                        setState(() => _geminiObscure = !_geminiObscure);
                      },
                      title: 'Google Gemini',
                      subtitle: 'API gratuita com limite generoso',
                      icon: '✨',
                      instructionsUrl: 'https://ai.google.dev/gemini-api/docs/api-key',
                    ),
                    const SizedBox(height: 16),

                    // Claude section
                    _buildProviderSection(
                      context: context,
                      provider: provider,
                      aiProvider: AIProvider.claude,
                      controller: _claudeController,
                      obscure: _claudeObscure,
                      onObscureToggle: () {
                        setState(() => _claudeObscure = !_claudeObscure);
                      },
                      title: 'Anthropic Claude',
                      subtitle: 'Modelo avançado com raciocínio superior',
                      icon: '🤖',
                      instructionsUrl: 'https://console.anthropic.com/settings/keys',
                    ),
                    const SizedBox(height: 24),

                    // How to get API keys
                    _buildHowToSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSection({
    required BuildContext context,
    required AIAssistantProvider provider,
    required AIProvider aiProvider,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onObscureToggle,
    required String title,
    required String subtitle,
    required String icon,
    required String instructionsUrl,
  }) {
    final isConfigured = provider.isProviderConfigured(aiProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2d3561), Color(0xFF1f2544)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF5A67D8).withOpacity(0.3),
                      const Color(0xFF6B46C1).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isConfigured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Configurado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // API Key input
          TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Chave de API',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              hintText: 'Cole sua chave de API aqui',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF5A67D8), width: 2),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white.withOpacity(0.7),
                ),
                onPressed: onObscureToggle,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => _saveApiKey(context, provider, aiProvider, controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A67D8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isConfigured ? 'Atualizar' : 'Salvar',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              if (isConfigured) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _removeApiKey(context, provider, aiProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Remover'),
                  ),
                ),
              ],
            ],
          ),
          if (isConfigured) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Testar'),
                    onPressed: () => _testConnection(context, provider, aiProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.list_alt, size: 18),
                    label: const Text('Modelos'),
                    onPressed: () => _showAvailableModels(context, provider, aiProvider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),

          // Instructions link
          TextButton.icon(
            icon: const Icon(Icons.open_in_new, size: 16, color: Color(0xFF5A67D8)),
            label: const Text(
              'Como obter uma chave de API',
              style: TextStyle(color: Color(0xFF5A67D8)),
            ),
            onPressed: () => _openInstructions(instructionsUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFBD38D).withOpacity(0.2),
            const Color(0xFFF59E0B).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBD38D), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Como obter chaves de API',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '1',
            'Google Gemini (Recomendado)',
            'Acesse ai.google.dev, faça login com sua conta Google e crie uma nova chave de API. É gratuito!',
          ),
          const SizedBox(height: 12),
          _buildInstructionStep(
            '2',
            'Anthropic Claude',
            'Acesse console.anthropic.com, crie uma conta e gere uma chave de API. Requer cartão de crédito, mas oferece créditos iniciais.',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFBD38D), Color(0xFFF59E0B)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveApiKey(
    BuildContext context,
    AIAssistantProvider provider,
    AIProvider aiProvider,
    TextEditingController controller,
  ) async {
    if (controller.text.trim().isEmpty) {
      _showMessage(context, 'Por favor, insira uma chave de API');
      return;
    }

    await provider.setApiKey(aiProvider, controller.text.trim());

    if (provider.hasError) {
      _showMessage(context, provider.errorMessage ?? 'Erro ao salvar');
    } else {
      _showMessage(context, 'Chave de API salva com sucesso!');
      controller.clear();
    }
  }

  Future<void> _removeApiKey(
    BuildContext context,
    AIAssistantProvider provider,
    AIProvider aiProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d3561),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remover chave de API?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Você não poderá usar o assistente IA com este provedor até configurar uma nova chave.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.removeApiKey(aiProvider);
      _showMessage(context, 'Chave de API removida');
    }
  }

  Future<void> _testConnection(
    BuildContext context,
    AIAssistantProvider provider,
    AIProvider aiProvider,
  ) async {
    _showMessage(context, 'Testando conexão...');

    final success = await provider.testConnection(aiProvider);

    if (success) {
      _showMessage(context, '✅ Conexão bem-sucedida!');
    } else {
      _showMessage(context, '❌ Falha na conexão. Verifique sua chave de API.');
    }
  }

  Future<void> _showAvailableModels(
    BuildContext context,
    AIAssistantProvider provider,
    AIProvider aiProvider,
  ) async {
    _showMessage(context, 'Buscando modelos disponíveis...');

    final models = await provider.listAvailableModels(aiProvider);

    if (!mounted) return;

    if (models.isEmpty) {
      _showMessage(context, '❌ Não foi possível obter a lista de modelos');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d3561),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Modelos Disponíveis - ${aiProvider.displayName}',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: models.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.check_circle, color: Color(0xFF10B981)),
                title: Text(
                  models[index],
                  style: const TextStyle(color: Colors.white),
                ),
                dense: true,
              );
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5A67D8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _openInstructions(String url) {
    // This would typically use url_launcher package
    _showMessage(context, 'Abra em seu navegador: $url');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
