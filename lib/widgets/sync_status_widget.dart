// lib/widgets/sync_status_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/unified_inventory_provider.dart';
import '../services/unified_sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: UnifiedSyncService().statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getStatusColor(status).withOpacity(0.3),
              width: 1,
            ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
              _buildStatusIcon(status),
            const SizedBox(width: 8),
                  Text(
                _getStatusText(status),
                    style: TextStyle(
                  color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              if (status == SyncStatus.syncing) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(status)),
                      ),
                    ),
                ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icon(
          Icons.cloud_done,
          size: 16,
          color: _getStatusColor(status),
        );
      case SyncStatus.syncing:
        return Icon(
          Icons.sync,
          size: 16,
          color: _getStatusColor(status),
        );
      case SyncStatus.success:
        return Icon(
          Icons.check_circle,
          size: 16,
          color: _getStatusColor(status),
        );
      case SyncStatus.error:
        return Icon(
          Icons.error,
          size: 16,
          color: _getStatusColor(status),
        );
      case SyncStatus.offline:
        return Icon(
          Icons.cloud_off,
          size: 16,
          color: _getStatusColor(status),
        );
    }
  }

  Color _getStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Colors.grey;
      case SyncStatus.syncing:
        return Colors.blue;
      case SyncStatus.success:
        return Colors.green;
      case SyncStatus.error:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.orange;
    }
  }

  String _getStatusText(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
    return 'Sincronizado';
      case SyncStatus.syncing:
        return 'Sincronizando...';
      case SyncStatus.success:
        return 'Actualizado';
      case SyncStatus.error:
        return 'Error';
      case SyncStatus.offline:
        return 'Sin conexión';
    }
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: UnifiedSyncService().statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? SyncStatus.idle;
        final isSyncing = status == SyncStatus.syncing;
        
        return IconButton(
          icon: isSyncing 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          onPressed: isSyncing ? null : () => _sync(context),
          tooltip: 'Sincronizar',
        );
      },
    );
  }

  void _sync(BuildContext context) {
    final provider = Provider.of<UnifiedInventoryProvider>(context, listen: false);
    provider.sincronizar();
  }
}

class SyncResultDialog extends StatelessWidget {
  final SyncResult result;

  const SyncResultDialog({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            result.success ? Icons.check_circle : Icons.error,
            color: result.success ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(result.success ? 'Sincronización Exitosa' : 'Error en Sincronización'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.message),
          if (result.itemsSynced > 0) ...[
            const SizedBox(height: 8),
            Text('Elementos sincronizados: ${result.itemsSynced}'),
          ],
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Errores:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.errors.map((error) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $error',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}