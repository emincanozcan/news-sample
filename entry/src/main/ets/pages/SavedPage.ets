import { AppNav } from '../models/NavigationModels';
import { ArticleSummary } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { ReadingStateService } from '../services/ReadingStateService';
import { ArticleListItem } from '../components/ArticleListItem';
import { StatePanel } from '../components/StatePanel';

@Component
export struct SavedPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State items: ArticleSummary[] = [];
  @State isLoading: boolean = true;
  @State hasLoadError: boolean = false;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text($r('app.string.saved_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)

          if (this.isLoading) {
            StatePanel({
              title: $r('app.string.state_loading'),
              subtitle: $r('app.string.saved_empty_subtitle')
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
              title: $r('app.string.saved_empty_title'),
              subtitle: $r('app.string.saved_empty_subtitle')
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
                ReadingStateService.clearSaved().then(() => {
                  this.refresh();
                });
              })
            ForEach(this.items, (item: ArticleSummary) => {
              ArticleListItem({
                article: item,
                actionLabel: $r('app.string.action_remove'),
                onOpen: () => {
                  AppNav.toArticleDetail(this.pageStack, { articleId: item.id, fromTopicId: item.topicId });
                },
                onAction: () => {
                  ReadingStateService.removeSaved(item.id).then(() => {
                    this.refresh();
                  });
                }
              })
            }, (item: ArticleSummary) => item.id)
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
        this.items = NewsRepository.getSavedFeed(ReadingStateService.getSavedItems());
      } catch (_error) {
        this.hasLoadError = true;
      }
      this.isLoading = false;
    }, 120);
  }
}
