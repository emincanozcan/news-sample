import { PreferenceKeys, PreferencesService } from '../services/PreferencesService';

const DEFAULT_TOPIC_IDS_JSON = JSON.stringify(['top', 'sports']);

function parseTopicIds(json: string): string[] {
  try {
    const parsed = JSON.parse(json) as string[];
    if (!Array.isArray(parsed)) {
      return ['top', 'sports'];
    }
    return parsed.filter((item: string) => item.length > 0);
  } catch (_error) {
    return ['top', 'sports'];
  }
}

export class AppSettingsStore {
  static hydratePersistentUiState(): void {
    PersistentStorage.persistProp(PreferenceKeys.onboardingDone, false);
    PersistentStorage.persistProp(PreferenceKeys.reminderEnabled, false);
    PersistentStorage.persistProp(PreferenceKeys.reminderHour, 8);
    PersistentStorage.persistProp(PreferenceKeys.scheduledReminderId, -1);
    PersistentStorage.persistProp(PreferenceKeys.preferredTopicIdsJson, DEFAULT_TOPIC_IDS_JSON);
    PersistentStorage.persistProp(PreferenceKeys.lastOpenedArticleId, '');

    const onboardingDone = PreferencesService.getBoolean(PreferenceKeys.onboardingDone, false);
    const reminderEnabled = PreferencesService.getBoolean(PreferenceKeys.reminderEnabled, false);
    const reminderHour = PreferencesService.getNumber(PreferenceKeys.reminderHour, 8);
    const scheduledReminderId = PreferencesService.getNumber(PreferenceKeys.scheduledReminderId, -1);
    const preferredTopicIdsJson = PreferencesService.getString(PreferenceKeys.preferredTopicIdsJson, DEFAULT_TOPIC_IDS_JSON);
    const lastOpenedArticleId = PreferencesService.getString(PreferenceKeys.lastOpenedArticleId, '');

    AppStorage.setOrCreate(PreferenceKeys.onboardingDone, onboardingDone);
    AppStorage.setOrCreate(PreferenceKeys.reminderEnabled, reminderEnabled);
    AppStorage.setOrCreate(PreferenceKeys.reminderHour, reminderHour);
    AppStorage.setOrCreate(PreferenceKeys.scheduledReminderId, scheduledReminderId);
    AppStorage.setOrCreate(PreferenceKeys.preferredTopicIdsJson, preferredTopicIdsJson);
    AppStorage.setOrCreate(PreferenceKeys.lastOpenedArticleId, lastOpenedArticleId);
  }

  static getPreferredTopicIds(): string[] {
    const value = AppStorage.get(PreferenceKeys.preferredTopicIdsJson) as string | undefined;
    return parseTopicIds(value ?? DEFAULT_TOPIC_IDS_JSON);
  }

  static async setPreferredTopicIds(topicIds: string[]): Promise<void> {
    const topicIdsJson = JSON.stringify(topicIds);
    AppStorage.setOrCreate(PreferenceKeys.preferredTopicIdsJson, topicIdsJson);
    await PreferencesService.putString(PreferenceKeys.preferredTopicIdsJson, topicIdsJson);
  }

  static async setReminderEnabled(enabled: boolean): Promise<void> {
    AppStorage.setOrCreate(PreferenceKeys.reminderEnabled, enabled);
    await PreferencesService.putBoolean(PreferenceKeys.reminderEnabled, enabled);
  }

  static async setReminderHour(hour24: number): Promise<void> {
    AppStorage.setOrCreate(PreferenceKeys.reminderHour, hour24);
    await PreferencesService.putNumber(PreferenceKeys.reminderHour, hour24);
  }

  static async setOnboardingDone(done: boolean): Promise<void> {
    AppStorage.setOrCreate(PreferenceKeys.onboardingDone, done);
    await PreferencesService.putBoolean(PreferenceKeys.onboardingDone, done);
  }

  static async setLastOpenedArticle(articleId: string): Promise<void> {
    AppStorage.setOrCreate(PreferenceKeys.lastOpenedArticleId, articleId);
    await PreferencesService.putString(PreferenceKeys.lastOpenedArticleId, articleId);
  }
}
