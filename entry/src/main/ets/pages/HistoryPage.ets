import { AppNav } from '../models/NavigationModels';
import { ArticleSummary, ReadHistoryEntry } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { ReadingStateService } from '../services/ReadingStateService';
import { ArticleListItem } from '../components/ArticleListItem';
import { StatePanel } from '../components/StatePanel';

interface HistoryListItem {
  article: ArticleSummary;
  readAt: number;
}

@Component
export struct HistoryPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State items: HistoryListItem[] = [];
  @State isLoading: boolean = true;
  @State hasLoadError: boolean = false;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text($r('app.string.history_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)

          if (this.isLoading) {
            StatePanel({
              title: $r('app.string.state_loading'),
              subtitle: $r('app.string.history_empty_subtitle')
            })
          } else if (this.hasLoadError) {
            StatePanel({
              title: $r('app.string.state_error_title'),
              subtitle: $r('app.string.state_error_subtitle')
            })
            Button($r('app.string.action_retry'))
              .fontSize(12)
              .fontColor($r('app.color.textPrimary'))
              .backgroundColor($r('app.color.surfaceChip'))
              .height(30)
              .borderRadius(15)
              .accessibilityText($r('app.string.action_retry'))
              .onClick(() => {
                this.refresh();
              })
          } else if (this.items.length === 0) {
            StatePanel({
              title: $r('app.string.history_empty_title'),
              subtitle: $r('app.string.history_empty_subtitle')
            })
          } else {
            Button($r('app.string.action_clear_all'))
              .fontSize(12)
              .fontColor($r('app.color.textPrimary'))
              .backgroundColor($r('app.color.surfaceChip'))
              .height(30)
              .borderRadius(15)
              .accessibilityText($r('app.string.action_clear_all'))
              .onClick(() => {
                ReadingStateService.clearHistory().then(() => {
                  this.refresh();
                });
              })
            ForEach(this.items, (item: HistoryListItem) => {
              ArticleListItem({
                article: item.article,
                timestampLabel: this.formatReadAt(item.readAt),
                actionLabel: $r('app.string.action_remove'),
                onOpen: () => {
                  AppNav.toArticleDetail(this.pageStack, { articleId: item.article.id, fromTopicId: item.article.topicId });
                },
                onAction: () => {
                  ReadingStateService.removeHistoryEntry(item.article.id).then(() => {
                    this.refresh();
                  });
                }
              })
            }, (item: HistoryListItem) => item.article.id)
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 18 })
      }
      .scrollBar(BarState.Off)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      this.refresh();
    })
    .onShown(() => {
      this.refresh();
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  private refresh(): void {
    this.isLoading = true;
    this.hasLoadError = false;
    setTimeout(() => {
      try {
        const history: ReadHistoryEntry[] = ReadingStateService.getReadHistory();
        const ordered: HistoryListItem[] = [];
        history.forEach((item: ReadHistoryEntry) => {
          const detail = NewsRepository.getArticleDetail(item.articleId);
          if (detail) {
            ordered.push({
              article: {
                id: detail.id,
                topicId: detail.topicId,
                title: detail.title,
                imageUrl: detail.imageUrl,
                source: detail.source,
                publishedAt: detail.publishedAt,
                readMinutes: detail.readMinutes,
                isBreaking: detail.isBreaking,
                tags: detail.tags
              },
              readAt: item.readAt
            });
          }
        });
        this.items = ordered;
      } catch (_error) {
        this.hasLoadError = true;
      }
      this.isLoading = false;
    }, 120);
  }

  private formatReadAt(readAt: number): string {
    const date = new Date(readAt);
    const month = `${date.getMonth() + 1}`.padStart(2, '0');
    const day = `${date.getDate()}`.padStart(2, '0');
    const hour = `${date.getHours()}`.padStart(2, '0');
    const minute = `${date.getMinutes()}`.padStart(2, '0');
    return `${month}/${day} ${hour}:${minute}`;
  }
}
