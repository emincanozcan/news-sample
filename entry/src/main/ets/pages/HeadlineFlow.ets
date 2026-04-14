import { AppNav, CategoryFeedNavParam } from '../models/NavigationModels';
import { ArticleSummary } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { ReadingStateService } from '../services/ReadingStateService';
import { HapticService } from '../services/HapticService';
import { common } from '@kit.AbilityKit';

@Component
export struct HeadlineFlow {
  @Consume('pageStack') pageStack: NavPathStack;
  @State currentIndex: number = 0;
  @State topicId: string = 'top';
  @State topicTitle: string = '';
  @State newsData: ArticleSummary[] = NewsRepository.getCategoryFeed('top');
  @State isCurrentSaved: boolean = false;

  build() {
    NavDestination() {
      Column({ space: 6 }) {
        Column({ space: 1 }) {
          Text($r('app.string.headline_topic_browser_label'))
            .fontSize(9)
            .fontColor($r('app.color.textSecondary'))
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .width('100%')
          Text(this.topicTitle)
            .fontSize(14)
            .fontColor($r('app.color.textPrimary'))
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          Text($r('app.string.headline_swipe_hint'))
            .fontSize(9)
            .fontColor($r('app.color.textSecondary'))
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .width('100%')
        }
        .width('100%')

        Swiper() {
          ForEach(
            this.newsData,
            (item: ArticleSummary) => {
              this.NewsCard(item)
            },
            (item: ArticleSummary) => item.id
          )
        }
        .index(this.currentIndex)
        .indicator(true)
        .loop(true)
        .vertical(false)
        .onChange((index: number) => {
          this.currentIndex = index;
          this.syncCurrentSavedState();
        })
        .width('100%')
        .height(118)

        Row({ space: 8 }) {
          Button($r('app.string.action_open'))
            .layoutWeight(1)
            .fontSize(11)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.surfaceChip'))
            .height(24)
            .borderRadius(12)
            .accessibilityText($r('app.string.a11y_open_article'))
            .onClick(() => {
              this.openCurrentArticle();
            })

          Button(this.isCurrentSaved ? $r('app.string.action_saved') : $r('app.string.action_save'))
            .layoutWeight(1)
            .fontSize(11)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor(this.isCurrentSaved ? $r('app.color.bookmarkAccent') : $r('app.color.backgroundColor'))
            .height(24)
            .borderRadius(12)
            .accessibilityText($r('app.string.a11y_quick_save'))
            .onClick(() => {
              this.toggleSaveCurrent();
            })
        }
        .width('100%')
        .padding({ left: 2, right: 2 })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 14, right: 14, top: 8, bottom: 8 })
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      const params = ctx.pathInfo.param as CategoryFeedNavParam | undefined;
      this.topicId = params?.topicId ?? 'top';
      const fallbackTopicTitle = NewsRepository.getTopics().find((item) => item.id === this.topicId)?.title ?? '';
      this.topicTitle = params?.topicTitle && params.topicTitle.length > 0
        ? params.topicTitle
        : fallbackTopicTitle;
      this.newsData = NewsRepository.getCategoryFeed(this.topicId);
      this.currentIndex = 0;
      this.syncCurrentSavedState();
    })
    .onShown(() => {
      this.syncCurrentSavedState();
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  private openCurrentArticle(): void {
    const current = this.newsData[this.currentIndex];
    if (current === undefined) {
      return;
    }
    AppNav.toArticleDetail(this.pageStack, {
      articleId: current.id,
      fromTopicId: current.topicId
    });
  }

  private toggleSaveCurrent(): void {
    const current = this.newsData[this.currentIndex];
    if (current === undefined) {
      return;
    }
    ReadingStateService.toggleSaved(current.id).then((savedNow: boolean) => {
      this.isCurrentSaved = savedNow;
      HapticService.pulseSuccess();
    });
  }

  private syncCurrentSavedState(): void {
    const current = this.newsData[this.currentIndex];
    this.isCurrentSaved = current !== undefined && ReadingStateService.isSaved(current.id);
  }

  @Builder
  NewsCard(item: ArticleSummary): void {
    Column({ space: 0 }) {
      Image(item.imageUrl)
        .width('100%')
        .height(74)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 24, topRight: 24, bottomLeft: 0, bottomRight: 0 })

      Column({ space: 8 }) {
        Text(item.source)
          .fontSize(10)
          .fontColor($r('app.color.textSecondary'))
          .maxLines(1)
          .textAlign(TextAlign.Center)
        Text(item.title)
          .fontSize(15)
          .fontColor($r('app.color.textPrimary'))
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 10, bottom: 12 })
      .backgroundColor($r('app.color.surfaceCard'))
      .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 24, bottomRight: 24 })
      .alignItems(HorizontalAlign.Center)

    }
    .width('100%')
    .height(118)
    .onClick(() => {
      AppNav.toArticleDetail(this.pageStack, {
        articleId: item.id,
        fromTopicId: item.topicId
      });
    })
    .accessibilityText(`${this.getString($r('app.string.a11y_open_article'))}: ${item.title}`)
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
