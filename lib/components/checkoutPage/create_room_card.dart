import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:seefood/data/app_env.dart';
import 'package:seefood/rooms/room_api.dart';
import 'package:seefood/rooms/room_models.dart';
import 'package:seefood/themes/app_colors.dart';

class CreateRoomCard extends StatefulWidget {
  const CreateRoomCard({
    super.key,
    required this.studentId,
    this.onRoomChanged,
  });

  final int? studentId;
  final ValueChanged<RoomModel?>? onRoomChanged;

  @override
  State<CreateRoomCard> createState() => _CreateRoomCardState();
}

class _CreateRoomCardState extends State<CreateRoomCard>
    with TickerProviderStateMixin {
  late final RoomApi _roomApi;
  RoomModel? _room;
  String? _roomCode;
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
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final studentId = widget.studentId;
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login to create a room')),
      );
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      final result = await _roomApi.createRoom(ownerId: studentId);
      _roomCode = result.code;
      _expanded = true;
      await _connectRoomSocket(result.code);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create room failed: $e')),
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
        _roomCode = room.code;
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
                        'Create Room',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Split the bill before order',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _loading ? null : _handleCreate,
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
                      : const Text('Create'),
                ),
              ],
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
                      _roomCode ?? '------',
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
