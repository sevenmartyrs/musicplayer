import 'package:flutter/material.dart';

class JellyfinServer {
  final String name;
  final String protocol;
  final String address;
  final String port;
  final String username;
  final String password;
  final String? path;

  JellyfinServer({
    required this.name,
    required this.protocol,
    required this.address,
    required this.port,
    required this.username,
    required this.password,
    this.path,
  });

  String get fullAddress => '$protocol://$address:$port${path ?? ''}';
}

class JellyfinPage extends StatefulWidget {
  const JellyfinPage({super.key});

  @override
  State<JellyfinPage> createState() => _JellyfinPageState();
}

class _JellyfinPageState extends State<JellyfinPage> {
  final List<JellyfinServer> _servers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '音乐库',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 已连接
            if (_servers.isNotEmpty) ...[
              _buildSectionHeader('已连接'),
              const SizedBox(height: 8),
              ..._servers.map((server) => _buildServerCard(server)),
              const SizedBox(height: 24),
            ],
            // 连接到
            _buildSectionHeader('连接到'),
            const SizedBox(height: 8),
            _buildJellyfinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF999999),
        ),
      ),
    );
  }

  Widget _buildJellyfinButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF00A4DC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showAddJellyfinServerDialog();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    size: 32,
                    color: Color(0xFF00A4DC),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jellyfin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '添加 Jellyfin 服务器',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerCard(JellyfinServer server) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00A4DC).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.storage,
              color: Color(0xFF00A4DC),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  server.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${server.address}:${server.port}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF8E8E93)),
            onPressed: () {
              setState(() {
                _servers.remove(server);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showAddJellyfinServerDialog() {
    final nameController = TextEditingController();
    final protocol = 'http';
    final addressController = TextEditingController();
    final portController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final pathController = TextEditingController();

    void disposeControllers() {
      nameController.dispose();
      addressController.dispose();
      portController.dispose();
      usernameController.dispose();
      passwordController.dispose();
      pathController.dispose();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isFormValid = addressController.text.isNotEmpty &&
              portController.text.isNotEmpty &&
              usernameController.text.isNotEmpty;

          return AlertDialog(
            title: const Text('添加 Jellyfin 服务器'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: protocol,
                    decoration: const InputDecoration(
                      labelText: '协议',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'http', child: Text('HTTP')),
                      DropdownMenuItem(value: 'https', child: Text('HTTPS')),
                    ],
                    onChanged: (value) {
                      // 协议选择，暂时固定为 http
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: '地址 *',
                      hintText: '192.168.1.100',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: portController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '端口 *',
                      hintText: '8096',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名 *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setDialogState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pathController,
                    decoration: const InputDecoration(
                      labelText: '路径',
                      hintText: '/jellyfin',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  disposeControllers();
                  Navigator.pop(context);
                },
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: isFormValid
                    ? () {
                        final server = JellyfinServer(
                          name: nameController.text.isNotEmpty
                              ? nameController.text
                              : 'Jellyfin 服务器',
                          protocol: protocol,
                          address: addressController.text,
                          port: portController.text,
                          username: usernameController.text,
                          password: passwordController.text,
                          path: pathController.text.isNotEmpty
                              ? pathController.text
                              : null,
                        );
                        setState(() {
                          _servers.add(server);
                        });
                        disposeControllers();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已添加服务器: ${server.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A4DC),
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                ),
                child: const Text('添加'),
              ),
            ],
          );
        },
      ),
    );
  }
}