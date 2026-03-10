import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seefood/data/app_env.dart';
import 'package:seefood/rooms/room_api.dart';
import 'package:seefood/rooms/room_models.dart';
import 'package:seefood/themes/app_colors.dart';

class JoinRoomCard extends StatefulWidget {
  const JoinRoomCard({
    super.key,
    required this.studentId,
    this.onRoomChanged,
  });

  final int? studentId;
  final ValueChanged<RoomModel?>? onRoomChanged;

  @override
  State<JoinRoomCard> createState() => _JoinRoomCardState();
}

class _JoinRoomCardState extends State<JoinRoomCard>
    with TickerProviderStateMixin {
  late final RoomApi _roomApi;
  final TextEditingController _codeController = TextEditingController();
  RoomModel? _room;
  bool _expanded = false;
  bool _loading = false;
  WebSocket? _socket;

  @override
  void initState() {
    super.initState();
    _roomApi = RoomApi();
  }

  @override
  void dispose() {
    _roomApi.close();
    _socket?.close();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final studentId = widget.studentId;
    final code = _codeController.text.trim().toUpperCase();
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login to join a room')),
      );
      return;
    }
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a room code')),
      );
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      await _roomApi.joinRoom(code: code, studentId: studentId);
      await _connectRoomSocket(code);
      final room = await _roomApi.fetchRoom(code: code);
      setState(() {
        _room = room;
        _expanded = true;
      });
      widget.onRoomChanged?.call(room);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Join room failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connectRoomSocket(String code) async {
    _socket?.close();
    final wsUri = _buildWsUri(code);
    try {
      final socket = await WebSocket.connect(wsUri.toString());
      _socket = socket;
      socket.listen((msg) {
        _handleRoomMessage(msg);
      }, onError: (_) {}, onDone: () {
        _socket = null;
      });
    } catch (_) {
      // ignore
    }
  }

  Uri _buildWsUri(String code) {
    final base = Uri.parse(AppEnv.apiBaseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final host = (Platform.isAndroid &&
            (base.host == 'localhost' || base.host == '127.0.0.1'))
        ? '10.0.2.2'
        : base.host;
    return Uri(
      scheme: scheme,
      host: host,
      port: base.hasPort ? base.port : null,
      path: '/ws',
      queryParameters: {'roomCode': code},
    );
  }

  void _handleRoomMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message.toString());
      if (decoded is! Map<String, dynamic>) return;
      final type = decoded['type']?.toString();
      if (type != 'room_snapshot' && type != 'room_update') return;
      final roomJson = decoded['room'];
      if (roomJson is! Map<String, dynamic>) return;
      final room = RoomModel.fromJson(roomJson);
      setState(() {
        _room = room;
        _expanded = true;
      });
      widget.onRoomChanged?.call(room);
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _room?.members ?? const [];

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.foreground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Join Room',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Enter room code to split the bill',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _loading ? null : _handleJoin,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Join'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter room code',
                filled: true,
                fillColor: AppColors.grayground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.grayground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Room Code',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _room?.code ?? '------',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (members.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...members.map(
                  (member) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              member.name.characters.first.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          member.status.toUpperCase(),
                          style: TextStyle(
                            color: member.status.toUpperCase() == 'PAID'
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
