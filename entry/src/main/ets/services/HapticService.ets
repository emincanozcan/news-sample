import { vibrator } from '@kit.SensorServiceKit';

export class HapticService {
  static async pulseSuccess(): Promise<boolean> {
    try {
      const supported = await vibrator.isSupportEffect('haptic.notice.success');
      if (!supported) {
        return false;
      }
      await vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.notice.success',
        count: 1
      }, {
        usage: 'unknown'
      });
      return true;
    } catch (_error) {
      return false;
    }
  }

  static async pulseLight(): Promise<boolean> {
    try {
      const supported = await vibrator.isSupportEffect('haptic.clock.timer');
      if (!supported) {
        return HapticService.pulseSuccess();
      }
      await vibrator.startVibration({
        type: 'preset',
        effectId: 'haptic.clock.timer',
        count: 1
      }, {
        usage: 'unknown'
      });
      return true;
    } catch (_error) {
      return false;
    }
  }
}
