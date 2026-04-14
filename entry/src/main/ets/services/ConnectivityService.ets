import { connection } from '@kit.NetworkKit';

export interface ConnectivityState {
  supported: boolean;
  online: boolean;
}

export class ConnectivityService {
  static getState(): ConnectivityState {
    try {
      if (!connection.hasDefaultNetSync()) {
        return {
          supported: true,
          online: false
        };
      }
      const handle = connection.getDefaultNetSync();
      if (!handle || handle.netId === 0) {
        return {
          supported: true,
          online: false
        };
      }
      const netCapabilities = connection.getNetCapabilitiesSync(handle);
      const caps = netCapabilities.networkCap;
      const checking = caps?.includes(connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY) ?? false;
      const validated = caps?.includes(connection.NetCap.NET_CAPABILITY_VALIDATED) ?? false;
      return {
        supported: true,
        online: !checking && validated
      };
    } catch (_error) {
      return {
        supported: false,
        online: true
      };
    }
  }
}
