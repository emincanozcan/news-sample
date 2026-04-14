import { common } from '@kit.AbilityKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { notificationManager } from '@kit.NotificationKit';
import { PreferenceKeys, PreferencesService } from './PreferencesService';

export interface ReminderStatus {
  enabled: boolean;
  capabilityKnown: boolean;
}

export interface ScheduledReminderResult {
  supported: boolean;
  effectiveEnabled: boolean;
  scheduled: boolean;
}

export class ReminderService {
  private static readonly SCHEDULED_NOTIFICATION_ID: number = 2001;
  private static readonly TEST_REMINDER_ID: number = 2002;
  private static readonly DAILY_REPEAT_DAYS: number[] = [1, 2, 3, 4, 5, 6, 7];
  private static appContext?: common.UIAbilityContext;

  static setContext(context: common.UIAbilityContext): void {
    ReminderService.appContext = context;
  }

  static async queryStatus(): Promise<ReminderStatus> {
    try {
      const enabled = await notificationManager.isNotificationEnabled();
      return { enabled: enabled, capabilityKnown: true };
    } catch (_error) {
      return { enabled: false, capabilityKnown: false };
    }
  }

  static async requestEnable(context: common.UIAbilityContext): Promise<ReminderStatus> {
    try {
      await notificationManager.requestEnableNotification(context);
      return ReminderService.queryStatus();
    } catch (_error) {
      return ReminderService.queryStatus();
    }
  }

  static async openNotificationSettings(context: common.UIAbilityContext): Promise<void> {
    try {
      await notificationManager.openNotificationSettings(context);
    } catch (_error) {
      // no-op: settings panel may already be displayed or unsupported on device
    }
  }

  static async syncDailyReminder(hour24: number, requestedEnabled: boolean): Promise<ScheduledReminderResult> {
    const status = await ReminderService.queryStatus();
    if (!requestedEnabled) {
      await ReminderService.cancelScheduledBriefingReminder();
      return {
        supported: true,
        effectiveEnabled: false,
        scheduled: false
      };
    }

    if (!status.enabled) {
      return {
        supported: true,
        effectiveEnabled: false,
        scheduled: false
      };
    }

    try {
      await ReminderService.cancelScheduledBriefingReminder();
      const request: reminderAgentManager.ReminderRequestAlarm = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_ALARM,
        hour: hour24,
        minute: 0,
        daysOfWeek: ReminderService.DAILY_REPEAT_DAYS,
        title: ReminderService.getString($r('app.string.notification_briefing_title')),
        content: `${ReminderService.getString($r('app.string.notification_briefing_ready_prefix'))} ${ReminderService.hourLabel(hour24)} ${ReminderService.getString($r('app.string.notification_briefing_ready_suffix'))}`,
        notificationId: ReminderService.SCHEDULED_NOTIFICATION_ID,
        tapDismissed: true
      };
      const reminderId = await reminderAgentManager.publishReminder(request);
      await PreferencesService.putNumber(PreferenceKeys.scheduledReminderId, reminderId);
      return {
        supported: true,
        effectiveEnabled: true,
        scheduled: true
      };
    } catch (_error) {
      return {
        supported: true,
        effectiveEnabled: false,
        scheduled: false
      };
    }
  }

  static async publishTestReminder(hour24: number): Promise<boolean> {
    return ReminderService.publishBriefingNotification(hour24, ReminderService.TEST_REMINDER_ID);
  }

  private static async cancelScheduledBriefingReminder(): Promise<void> {
    const reminderId = PreferencesService.getNumber(PreferenceKeys.scheduledReminderId, -1);
    if (reminderId < 0) {
      return;
    }
    try {
      await reminderAgentManager.cancelReminder(reminderId);
    } catch (_error) {
      // no-op: reminder may already be gone
    }
    await PreferencesService.putNumber(PreferenceKeys.scheduledReminderId, -1);
  }

  private static async publishBriefingNotification(hour24: number, id: number): Promise<boolean> {
    try {
      const request: notificationManager.NotificationRequest = {
        id: id,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: ReminderService.getString($r('app.string.notification_briefing_title')),
            text: `${ReminderService.getString($r('app.string.notification_briefing_ready_prefix'))} ${ReminderService.hourLabel(hour24)} ${ReminderService.getString($r('app.string.notification_briefing_ready_suffix'))}`,
            additionalText: ReminderService.getString($r('app.string.notification_briefing_additional'))
          }
        }
      };
      await notificationManager.publish(request);
      return true;
    } catch (_error) {
      return false;
    }
  }

  static hourLabel(hour24: number): string {
    if (hour24 < 12) {
      return ReminderService.getString($r('app.string.time_morning'));
    }
    if (hour24 < 18) {
      return ReminderService.getString($r('app.string.time_afternoon'));
    }
    return ReminderService.getString($r('app.string.time_evening'));
  }

  private static getString(resource: ResourceStr): string {
    if (typeof resource === 'string') {
      return resource;
    }
    const context = ReminderService.appContext;
    if (!context) {
      return '';
    }
    try {
      return context.resourceManager.getStringSync(resource.id);
    } catch (_error) {
      return '';
    }
  }
}
