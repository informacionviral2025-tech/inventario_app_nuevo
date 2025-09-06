// lib/widgets/sync_status_widget.dart
import 'package:flutter/material.dart';
import '../services/sync_service.dart';

class SyncStatusWidget extends StatefulWidget {
  final VoidCallback? onSyncPressed;
  final bool showDetails;

  const SyncStatusWidget({
    super.key,
    this.onSyncPressed,
    this.showDetails = true,
  });

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  final SyncService _syncService = SyncService();
  SyncInfo? _syncInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSyncInfo();
    
    // Escuchar cambios en el estado de sincronización
    _syncService.syncStatusStream.listen((_) {
      _loadSyncInfo();
    });
  }

  Future<void> _loadSyncInfo() async {
    try {
      final info = await _syncService.getSyncInfo();
      if (mounted) {
        setState(() {
          _syncInfo = info;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncInfo = SyncInfo(
            hasInternetConnection: false,
            isSyncing: false,
            pendingSyncCount: 0,
            conflictedCount: 0,
            lastSync: null,
          );
        });
      }
    }
  }

  Future<void> _handleSync() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    try {
      if (widget.onSyncPressed != null) {
        await widget.onSyncPressed!();
      } else {
        await _syncService.syncAll();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_syncInfo == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _syncInfo!.hasInternetConnection && !_syncInfo!.isSyncing ? _handleSync : null,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor().withOpacity(0.1),
          border: Border.all(color: _getStatusColor()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(_getStatusColor()),
                    ),
                  )
                : Icon(
                    _getStatusIcon(),
                    size: 16,
                    color: _getStatusColor(),
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.showDetails && (_syncInfo!.pendingSyncCount > 0 || _syncInfo!.conflictedCount > 0))
                    Text(
                      _getDetailsText(),
                      style: TextStyle(
                        color: _getStatusColor().withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  if (_syncInfo!.lastSync != null && widget.showDetails)
                    Text(
                      'Última sync: ${_formatLastSync(_syncInfo!.lastSync!)}',
                      style: TextStyle(
                        color: _getStatusColor().withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            if (_syncInfo!.hasInternetConnection && !_syncInfo!.isSyncing && !_isLoading)
              Icon(
                Icons.refresh,
                size: 16,
                color: _getStatusColor(),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (_syncInfo!.isSyncing || _isLoading) return Colors.blue;
    if (!_syncInfo!.hasInternetConnection) return Colors.grey;
    if (_syncInfo!.conflictedCount > 0) return Colors.red;
    if (_syncInfo!.pendingSyncCount > 0) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon() {
    if (_syncInfo!.isSyncing) return Icons.sync;
    if (!_syncInfo!.hasInternetConnection) return Icons.wifi_off;
    if (_syncInfo!.conflictedCount > 0) return Icons.error_outline;
    if (_syncInfo!.pendingSyncCount > 0) return Icons.cloud_upload;
    return Icons.cloud_done;
  }

  String _getStatusText() {
    if (_syncInfo!.isSyncing) return 'Sincronizando...';
    if (!_syncInfo!.hasInternetConnection) return 'Sin conexión';
    if (_syncInfo!.conflictedCount > 0) return 'Conflictos detectados';
    if (_syncInfo!.pendingSyncCount > 0) return 'Pendiente sincronización';
    return 'Sincronizado';
  }

  String _getDetailsText() {
    final pending = _syncInfo!.pendingSyncCount;
    final conflicts = _syncInfo!.conflictedCount;
    
    List<String> details = [];
    if (pending > 0) details.add('$pending pendientes');
    if (conflicts > 0) details.add('$conflicts conflictos');
    
    return details.join(' • ');
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
    if (difference.inMinutes < 1) return 'ahora mismo';
    if (difference.inMinutes < 60) return 'hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'hace ${difference.inHours} h';
    return 'hace ${difference.inDays} días';
  }
}