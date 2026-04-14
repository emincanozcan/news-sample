import { common } from '@kit.AbilityKit';
import { AppNav } from '../models/NavigationModels';
import { HapticService } from '../services/HapticService';
import { PreferenceKeys } from '../services/PreferencesService';
import { ReminderService } from '../services/ReminderService';
import { AppSettingsStore } from '../store/AppSettingsStore';

@Component
export struct SettingsPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State reminderRequested: boolean = false;
  @State reminderEnabled: boolean = false;
  @State reminderHour: number = 8;
  @State notificationEnabled: boolean = false;
  @State reminderHint: string = '';
  @State testHint: string = '';
  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text($r('app.string.settings_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)

          this.Tile(
            $r('app.string.settings_reminder_toggle'),
            this.reminderEnabled
              ? $r('app.string.status_enabled')
              : (this.reminderRequested ? $r('app.string.status_permission_needed') : $r('app.string.status_disabled')),
            () => {
              this.toggleReminder();
            }
          )

          this.Tile(
            $r('app.string.settings_reminder_morning'),
            this.reminderHour === 8 ? $r('app.string.status_selected') : $r('app.string.status_tap_to_select'),
            () => {
              this.setReminderHour(8);
            }
          )

          this.Tile(
            $r('app.string.settings_reminder_evening'),
            this.reminderHour === 19 ? $r('app.string.status_selected') : $r('app.string.status_tap_to_select'),
            () => {
              this.setReminderHour(19);
            }
          )

          Text(this.reminderHint)
            .fontColor($r('app.color.textPrimary'))
            .fontSize(11)
            .width('100%')
            .padding({ left: 10, right: 10, top: 7, bottom: 7 })
            .backgroundColor(this.notificationEnabled ? $r('app.color.statusSuccessBg') : $r('app.color.statusWarningBg'))
            .borderRadius(12)
            .textAlign(TextAlign.Center)

          Text(this.testHint)
            .fontColor($r('app.color.textSecondary'))
            .fontSize(11)
            .width('100%')

          Row({ space: 8 }) {
            Button($r('app.string.nav_briefing'))
              .layoutWeight(1)
              .fontSize(12)
              .fontColor($r('app.color.textPrimary'))
              .backgroundColor($r('app.color.surfaceChip'))
              .height(32)
              .borderRadius(16)
              .onClick(() => {
                AppNav.toBriefing(this.pageStack, { source: 'settings' });
              })

            Button($r('app.string.action_test_reminder'))
              .layoutWeight(1)
              .fontSize(12)
              .fontColor($r('app.color.textPrimary'))
              .backgroundColor($r('app.color.backgroundColor'))
              .height(32)
              .borderRadius(16)
              .enabled(this.notificationEnabled)
              .onClick(() => {
                this.publishTestReminder();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 20 })
      }
      .scrollBar(BarState.Off)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      this.reload();
    })
    .onShown(() => {
      this.reload();
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  @Builder
  private Tile(title: ResourceStr, subtitle: ResourceStr, onTap: () => void) {
    Column({ space: 2 }) {
      Text(title)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(13)
        .width('100%')
      Text(subtitle)
        .fontColor($r('app.color.textSecondary'))
        .fontSize(11)
        .width('100%')
    }
    .width('100%')
    .padding({ left: 10, right: 10, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.surfaceCard'))
    .borderRadius(12)
    .onClick(() => {
      onTap();
    })
  }

  private reload(): void {
    this.testHint = this.getString($r('app.string.settings_test_hint'));
    this.reminderRequested = (AppStorage.get(PreferenceKeys.reminderEnabled) as boolean | undefined) ?? false;
    this.reminderHour = (AppStorage.get(PreferenceKeys.reminderHour) as number | undefined) ?? 8;
    ReminderService.queryStatus().then((status) => {
      this.notificationEnabled = status.enabled;
      this.reminderEnabled = this.reminderRequested && status.enabled;
      this.reminderHint = this.reminderEnabled
        ? this.getString($r('app.string.settings_reminder_effective_hint'))
        : (this.reminderRequested
          ? this.getString($r('app.string.settings_reminder_pending_hint'))
          : this.getString($r('app.string.settings_reminder_disabled_hint')));
    });
  }

  private toggleReminder(): void {
    if (!this.reminderRequested) {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      ReminderService.requestEnable(context).then((status) => {
        this.notificationEnabled = status.enabled;
        this.reminderRequested = true;
        this.reminderEnabled = status.enabled;
        AppSettingsStore.setReminderEnabled(status.enabled);
        this.reminderHint = this.reminderEnabled
          ? this.getString($r('app.string.settings_reminder_effective_hint'))
          : this.getString($r('app.string.settings_reminder_pending_hint'));
        ReminderService.syncDailyReminder(this.reminderHour, this.reminderRequested);
        if (!status.enabled) {
          ReminderService.openNotificationSettings(context);
          HapticService.pulseLight();
          return;
        }
        HapticService.pulseSuccess();
      });
      return;
    }

    if (this.reminderRequested && !this.notificationEnabled) {
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      ReminderService.openNotificationSettings(context);
      HapticService.pulseLight();
      return;
    }

    this.reminderRequested = false;
    this.reminderEnabled = false;
    AppSettingsStore.setReminderEnabled(false);
    ReminderService.syncDailyReminder(this.reminderHour, this.reminderRequested);
    this.reminderHint = this.getString($r('app.string.settings_reminder_disabled_hint'));
    HapticService.pulseLight();
  }

  private setReminderHour(hour: number): void {
    this.reminderHour = hour;
    AppSettingsStore.setReminderHour(hour);
    ReminderService.syncDailyReminder(hour, this.reminderRequested);
    HapticService.pulseLight();
  }

  private publishTestReminder(): void {
    ReminderService.publishTestReminder(this.reminderHour).then((ok: boolean) => {
      this.testHint = ok
        ? this.getString($r('app.string.settings_test_sent'))
        : this.getString($r('app.string.settings_test_failed'));
    });
  }

  private getString(resource: ResourceStr): string {
    if (typeof resource === 'string') {
      return resource;
    }
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      return context.resourceManager.getStringSync(resource.id);
    } catch (_error) {
      return '';
    }
  }
}
