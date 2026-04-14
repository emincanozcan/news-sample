import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ReadingStateService } from '../services/ReadingStateService';
import { AppStorageKeys, PreferencesService } from '../services/PreferencesService';
import { AppSettingsStore } from '../store/AppSettingsStore';
import { ReminderService } from '../services/ReminderService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate(AppStorageKeys.storageHydrated, false);
    ReminderService.setContext(this.context);
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (error) {
      hilog.error(DOMAIN, 'newsSample', 'setColorMode failed: %{public}s', JSON.stringify(error));
    }
    PreferencesService.init(this.context).catch((error: Object) => {
      hilog.error(DOMAIN, 'newsSample', 'Preferences init failed: %{public}s', JSON.stringify(error));
    }).then(() => {
      AppSettingsStore.hydratePersistentUiState();
      return ReadingStateService.hydrateFromPreferences();
    }).catch((error: Object) => {
      hilog.error(DOMAIN, 'newsSample', 'Storage hydration failed: %{public}s', JSON.stringify(error));
    }).finally(() => {
      AppStorage.setOrCreate(AppStorageKeys.storageHydrated, true);
    });
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
