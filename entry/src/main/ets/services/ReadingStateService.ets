import { ReadHistoryEntry, SavedItem } from '../models/NewsModels';
import { PreferenceKeys, PreferencesService } from './PreferencesService';
import { AppSettingsStore } from '../store/AppSettingsStore';

const HISTORY_LIMIT = 40;

function parseSavedItems(json: string): SavedItem[] {
  try {
    const parsed = JSON.parse(json) as SavedItem[];
    if (!Array.isArray(parsed)) {
      return [];
    }
    return parsed.filter((item: SavedItem) => typeof item.articleId === 'string' && typeof item.savedAt === 'number');
  } catch (_error) {
    return [];
  }
}

function parseReadHistory(json: string): ReadHistoryEntry[] {
  try {
    const parsed = JSON.parse(json) as ReadHistoryEntry[];
    if (!Array.isArray(parsed)) {
      return [];
    }
    return parsed.filter((item: ReadHistoryEntry) => typeof item.articleId === 'string' && typeof item.readAt === 'number');
  } catch (_error) {
    return [];
  }
}

export class ReadingStateService {
  static async hydrateFromPreferences(): Promise<void> {
    const savedJson = PreferencesService.getString(PreferenceKeys.bookmarksJson, '[]');
    const historyJson = PreferencesService.getString(PreferenceKeys.historyJson, '[]');
    const savedItems = parseSavedItems(savedJson);
    const readHistory = parseReadHistory(historyJson);

    AppStorage.setOrCreate(PreferenceKeys.bookmarksJson, JSON.stringify(savedItems));
    AppStorage.setOrCreate(PreferenceKeys.historyJson, JSON.stringify(readHistory));
    AppStorage.setOrCreate('news.reading.bookmarkCount', savedItems.length);
    AppStorage.setOrCreate('news.reading.historyCount', readHistory.length);
  }

  static getSavedItems(): SavedItem[] {
    const savedJson = AppStorage.get(PreferenceKeys.bookmarksJson) as string | undefined;
    return parseSavedItems(savedJson ?? '[]');
  }

  static getReadHistory(): ReadHistoryEntry[] {
    const historyJson = AppStorage.get(PreferenceKeys.historyJson) as string | undefined;
    return parseReadHistory(historyJson ?? '[]');
  }

  static isSaved(articleId: string): boolean {
    return ReadingStateService.getSavedItems().some((item: SavedItem) => item.articleId === articleId);
  }

  static async toggleSaved(articleId: string): Promise<boolean> {
    const existing = ReadingStateService.getSavedItems();
    const currentIndex = existing.findIndex((item: SavedItem) => item.articleId === articleId);
    let next: SavedItem[] = [];
    let isSavedNow = false;
    if (currentIndex >= 0) {
      next = existing.filter((item: SavedItem) => item.articleId !== articleId);
    } else {
      next = [{ articleId: articleId, savedAt: Date.now() }, ...existing];
      isSavedNow = true;
    }

    await ReadingStateService.persistSaved(next);
    return isSavedNow;
  }

  static async removeSaved(articleId: string): Promise<void> {
    const next = ReadingStateService.getSavedItems().filter((item: SavedItem) => item.articleId !== articleId);
    await ReadingStateService.persistSaved(next);
  }

  static async clearSaved(): Promise<void> {
    await ReadingStateService.persistSaved([]);
  }

  static async recordRead(articleId: string): Promise<void> {
    const now = Date.now();
    const history = ReadingStateService.getReadHistory().filter((item: ReadHistoryEntry) => item.articleId !== articleId);
    history.unshift({ articleId: articleId, readAt: now });
    const bounded = history.slice(0, HISTORY_LIMIT);
    await ReadingStateService.persistHistory(bounded);
    await AppSettingsStore.setLastOpenedArticle(articleId);
  }

  static async clearHistory(): Promise<void> {
    await ReadingStateService.persistHistory([]);
  }

  static async removeHistoryEntry(articleId: string): Promise<void> {
    const next = ReadingStateService.getReadHistory().filter((item: ReadHistoryEntry) => item.articleId !== articleId);
    await ReadingStateService.persistHistory(next);
  }

  private static async persistSaved(items: SavedItem[]): Promise<void> {
    const serialized = JSON.stringify(items);
    AppStorage.setOrCreate(PreferenceKeys.bookmarksJson, serialized);
    AppStorage.setOrCreate('news.reading.bookmarkCount', items.length);
    await PreferencesService.putString(PreferenceKeys.bookmarksJson, serialized);
  }

  private static async persistHistory(items: ReadHistoryEntry[]): Promise<void> {
    const serialized = JSON.stringify(items);
    AppStorage.setOrCreate(PreferenceKeys.historyJson, serialized);
    AppStorage.setOrCreate('news.reading.historyCount', items.length);
    await PreferencesService.putString(PreferenceKeys.historyJson, serialized);
  }
}
