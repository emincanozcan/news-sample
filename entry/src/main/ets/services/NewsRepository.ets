import { SEEDED_ARTICLES, SEEDED_TOPICS } from '../data/seed/SeedNewsData';
import { ArticleDetail, ArticleSummary, DigestCard, ReadHistoryEntry, SavedItem, NewsTopic } from '../models/NewsModels';

function toSummary(detail: ArticleDetail): ArticleSummary {
  return {
    id: detail.id,
    topicId: detail.topicId,
    title: detail.title,
    imageUrl: detail.imageUrl,
    source: detail.source,
    publishedAt: detail.publishedAt,
    readMinutes: detail.readMinutes,
    isBreaking: detail.isBreaking,
    tags: detail.tags
  };
}

export class NewsRepository {
  static getTopics(): NewsTopic[] {
    return SEEDED_TOPICS;
  }

  static getCategoryFeed(topicId: string): ArticleSummary[] {
    return SEEDED_ARTICLES.filter((item: ArticleDetail) => item.topicId === topicId).map(toSummary);
  }

  static getPersonalizedFeed(topicIds: string[]): ArticleSummary[] {
    if (topicIds.length === 0) {
      return SEEDED_ARTICLES.slice(0, 4).map(toSummary);
    }

    const preferred: ArticleSummary[] = [];
    topicIds.forEach((topicId: string) => {
      const topForTopic = SEEDED_ARTICLES.find((item: ArticleDetail) => item.topicId === topicId);
      if (topForTopic) {
        preferred.push(toSummary(topForTopic));
      }
    });

    const breaking = SEEDED_ARTICLES.filter((item: ArticleDetail) => item.isBreaking).map(toSummary);
    const uniqueById = new Set<string>();
    const merged = [...preferred, ...breaking].filter((item: ArticleSummary) => {
      if (uniqueById.has(item.id)) {
        return false;
      }
      uniqueById.add(item.id);
      return true;
    });
    return merged.slice(0, 6);
  }

  static getSavedFeed(savedItems: SavedItem[]): ArticleSummary[] {
    const ids = new Set<string>(savedItems.map((item: SavedItem) => item.articleId));
    return SEEDED_ARTICLES.filter((item: ArticleDetail) => ids.has(item.id)).map(toSummary);
  }

  static getDigestCards(topicIds: string[], savedItems: SavedItem[], history: ReadHistoryEntry[]): DigestCard[] {
    const personalized = NewsRepository.getPersonalizedFeed(topicIds).slice(0, 3);
    return [
      {
        id: 'digest-top',
        headline: $r('app.string.briefing_card_top_headline'),
        subtitle: $r('app.string.briefing_card_top_subtitle_format', personalized.length),
        articleIds: personalized.map((item: ArticleSummary) => item.id)
      },
      {
        id: 'digest-saved',
        headline: $r('app.string.briefing_card_saved_headline'),
        subtitle: $r('app.string.briefing_card_saved_subtitle_format', savedItems.length),
        articleIds: savedItems.map((item: SavedItem) => item.articleId)
      },
      {
        id: 'digest-history',
        headline: $r('app.string.briefing_card_history_headline'),
        subtitle: $r('app.string.briefing_card_history_subtitle_format', history.length),
        articleIds: history.map((item: ReadHistoryEntry) => item.articleId)
      }
    ];
  }

  static getArticleDetail(articleId: string): ArticleDetail | undefined {
    return SEEDED_ARTICLES.find((item: ArticleDetail) => item.id === articleId);
  }
}
