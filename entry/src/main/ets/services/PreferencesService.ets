import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export class PreferenceKeys {
  static readonly preferredTopicIdsJson: string = 'news.settings.preferredTopicIdsJson';
  static readonly onboardingDone: string = 'news.settings.onboardingDone';
  static readonly reminderEnabled: string = 'news.settings.reminderEnabled';
  static readonly reminderHour: string = 'news.settings.reminderHour';
  static readonly scheduledReminderId: string = 'news.settings.scheduledReminderId';
  static readonly bookmarksJson: string = 'news.reading.bookmarksJson';
  static readonly historyJson: string = 'news.reading.historyJson';
  static readonly lastOpenedArticleId: string = 'news.reading.lastOpenedArticleId';
}

export class AppStorageKeys {
  static readonly storageHydrated: string = 'news.app.storageHydrated';
}

const STORE_NAME = 'news_sample_store';

export class PreferencesService {
  private static pref: preferences.Preferences | undefined = undefined;

  static async init(context: common.UIAbilityContext): Promise<void> {
    if (PreferencesService.pref !== undefined) {
      return;
    }
    try {
      PreferencesService.pref = await preferences.getPreferences(context, STORE_NAME);
    } catch (_error) {
      PreferencesService.pref = undefined;
    }
  }

  static ensureReady(): preferences.Preferences | undefined {
    if (PreferencesService.pref === undefined) {
      return undefined;
    }
    return PreferencesService.pref;
  }

  static getString(key: string, fallback: string): string {
    const pref = PreferencesService.ensureReady();
    if (pref === undefined) {
      return fallback;
    }
    try {
      return pref.getSync(key, fallback) as string;
    } catch (_error) {
      return fallback;
    }
  }

  static getNumber(key: string, fallback: number): number {
    const pref = PreferencesService.ensureReady();
    if (pref === undefined) {
      return fallback;
    }
    try {
      return pref.getSync(key, fallback) as number;
    } catch (_error) {
      return fallback;
    }
  }

  static getBoolean(key: string, fallback: boolean): boolean {
    const pref = PreferencesService.ensureReady();
    if (pref === undefined) {
      return fallback;
    }
    try {
      return pref.getSync(key, fallback) as boolean;
    } catch (_error) {
      return fallback;
    }
  }

  static async putString(key: string, value: string): Promise<void> {
    const pref = PreferencesService.ensureReady();
    if (pref === undefined) {
      return;
    }
    try {
      await pref.put(key, value);
      await pref.flush();
    } catch (_error) {
      return;
    }
  }

  static async putNumber(key: string, value: number): Promise<void> {
    const pref = PreferencesService.ensureReady();
    if (pref === undefined) {
      return;
    }
    try {
      await pref.put(key, value);
      await pref.flush();
    } catch (_error) {
      return;
    }
  }

  static async putBoolean(key: string, value: boolean): Promise<void> {
    const pref = PreferencesService.ensureReady();
    if (pref === undefined) {
      return;
    }
    try {
      await pref.put(key, value);
      await pref.flush();
    } catch (_error) {
      return;
    }
  }
}
