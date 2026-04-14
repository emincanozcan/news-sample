export interface NewsTopic {
  id: string;
  title: string;
  description: string;
  accentColor: string;
}

export interface ArticleSummary {
  id: string;
  topicId: string;
  title: string;
  imageUrl: Resource;
  source: string;
  publishedAt: string;
  readMinutes: number;
  isBreaking: boolean;
  tags: string[];
}

export interface ArticleDetail extends ArticleSummary {
  heroNote: string;
  summaryBullets: string[];
}

export interface DigestCard {
  id: string;
  headline: ResourceStr | string;
  subtitle: ResourceStr | string;
  articleIds: string[];
}

export interface SavedItem {
  articleId: string;
  savedAt: number;
}

export interface ReadHistoryEntry {
  articleId: string;
  readAt: number;
}
