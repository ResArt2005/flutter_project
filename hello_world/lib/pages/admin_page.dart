import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/photo_service.dart';
import 'login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _isLoggedIn = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = await AuthService.getCurrentUser();
    setState(() {
      _isLoggedIn = loggedIn;
      _username = user;
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    await _checkAuth();
  }

  Future<void> _navigateToLogin(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    if (result == true) {
      await _checkAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Администрирование'),
        actions: _isLoggedIn
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                  tooltip: 'Выйти',
                ),
              ]
            : [],
      ),
      body: Center(
        child: _isLoggedIn
            ? AdminTabs(username: _username)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Для доступа к администрированию требуется авторизация.',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _navigateToLogin(context),
                    child: const Text('Войти'),
                  ),
                ],
              ),
      ),
    );
  }
}

class AdminTabs extends StatefulWidget {
  final String? username;

  const AdminTabs({super.key, this.username});

  @override
  State<AdminTabs> createState() => _AdminTabsState();
}

class _AdminTabsState extends State<AdminTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await AuthService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
      _tabController = TabController(
        length: _isAdmin ? 2 : 1,
        vsync: this,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(icon: Icon(Icons.people), text: 'Пользователи'),
    ];
    final tabViews = <Widget>[
      UserManagementWidget(),
    ];
    if (_isAdmin) {
      tabs.add(const Tab(icon: Icon(Icons.photo_library), text: 'Фото'));
      tabViews.add(PhotoManagementWidget());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Добро пожаловать, ${widget.username ?? 'администратор'}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: tabViews,
          ),
        ),
      ],
    );
  }
}

class UserManagementWidget extends StatefulWidget {
  const UserManagementWidget({super.key});

  @override
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    final users = await DatabaseService.getUsers();
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Future<void> _addUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      _showSnackBar('Заполните имя и email');
      return;
    }
    final success = await DatabaseService.addUser(name, email, password: password);
    if (success) {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      await _loadUsers();
      _showSnackBar('Пользователь добавлен');
    } else {
      _showSnackBar('Ошибка добавления');
    }
  }

  Future<void> _deleteUser(int id) async {
    final success = await DatabaseService.deleteUser(id);
    if (success) {
      await _loadUsers();
      _showSnackBar('Пользователь удалён');
    } else {
      _showSnackBar('Ошибка удаления');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Управление пользователями',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Добавить нового пользователя',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Имя',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Пароль (опционально)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addUser,
                    child: const Text('Добавить пользователя'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Список пользователей',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user['id'].toString()),
                          ),
                          title: Text(user['name']),
                          subtitle: Text(user['email']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user['id']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class PhotoManagementWidget extends StatefulWidget {
  const PhotoManagementWidget({super.key});

  @override
  State<PhotoManagementWidget> createState() => _PhotoManagementWidgetState();
}

class _PhotoManagementWidgetState extends State<PhotoManagementWidget> {
  List<Photo> _photos = [];
  bool _loading = true;
  bool _isAdmin = false;
  final TextEditingController _filePickerController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkAdmin();
    if (_isAdmin) {
      await _loadPhotos();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkAdmin() async {
    final isAdmin = await AuthService.isAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadPhotos() async {
    if (!_isAdmin) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final photos = await PhotoService.getPhotos();
    setState(() {
      _photos = photos;
      _loading = false;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() {
      _selectedFile = result.files.first;
      _filePickerController.text = _selectedFile!.name;
    });
  }

  String _getMimeType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _uploadPhoto() async {
    if (!_isAdmin) {
      _showSnackBar('Требуются права администратора');
      return;
    }
    if (_selectedFile == null) {
      _showSnackBar('Сначала выберите файл');
      return;
    }
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      _showSnackBar('Ошибка: пользователь не авторизован');
      return;
    }
    try {
      final bytes = _selectedFile!.bytes!;
      final fileName = _selectedFile!.name;
      final mimeType = _getMimeType(_selectedFile!.extension);
      final photo = await PhotoService.uploadPhoto(
        bytes,
        fileName,
        mimeType,
        userId: userId,
      );
      if (photo != null) {
        _showSnackBar('Фото успешно загружено');
        await _loadPhotos();
        setState(() {
          _selectedFile = null;
          _filePickerController.clear();
        });
      } else {
        _showSnackBar('Ошибка загрузки фото');
      }
    } catch (e) {
      _showSnackBar('Ошибка: $e');
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    if (!_isAdmin) {
      _showSnackBar('Требуются права администратора');
      return;
    }
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) {
      _showSnackBar('Ошибка: пользователь не авторизован');
      return;
    }
    final success = await PhotoService.deletePhoto(photoId, userId: userId);
    if (success) {
      await _loadPhotos();
      _showSnackBar('Фото удалено');
    } else {
      _showSnackBar('Ошибка удаления');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'У вас недостаточно прав для управления фотографиями. Требуется роль администратора.',
            style: TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Управление фотографиями',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Загрузить новое фото',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _filePickerController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Файл не выбран',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.upload_file),
                        onPressed: _pickFile,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadPhoto,
                    child: const Text('Загрузить фото'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Список фотографий',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _photos.isEmpty
                  ? const Center(
                      child: Text('Нет загруженных фото', style: TextStyle(fontSize: 16)),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _photos.length,
                        itemBuilder: (context, index) {
                          final photo = _photos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        'http://localhost:8000${photo.filepath}'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              title: Text(photo.filename),
                              subtitle: Text(
                                  '${photo.size ~/ 1024} КБ • ${photo.uploadedAt.day}.${photo.uploadedAt.month}.${photo.uploadedAt.year}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletePhoto(photo.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}