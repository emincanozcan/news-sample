import { ArticleDetailNavParam, CategoryFeedNavParam } from '../models/NavigationModels';
import { ArticleDetail } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { ReadingStateService } from '../services/ReadingStateService';
import { StatePanel } from '../components/StatePanel';
import { Pages } from './Pages';
import { HapticService } from '../services/HapticService';

@Component
export struct ArticleDetailPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State article: ArticleDetail | undefined = undefined;
  @State isSaved: boolean = false;

  build() {
    NavDestination() {
      if (this.article === undefined) {
        Column() {
          StatePanel({
            title: $r('app.string.detail_not_found'),
            subtitle: $r('app.string.phase1_stub_message')
          })
        }
        .padding({ left: 14, right: 14, top: 20 })
      } else {
        Scroll() {
          Column({ space: 10 }) {
            Image(this.article.imageUrl)
              .width('100%')
              .height(104)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
            Text(this.article.title)
              .fontColor($r('app.color.textPrimary'))
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .maxLines(3)
            Text(`${this.article.source} · ${this.article.publishedAt} · ${this.article.readMinutes}m`)
              .fontColor($r('app.color.textSecondary'))
              .fontSize(12)
            Text(this.article.heroNote)
              .fontColor($r('app.color.textPrimary'))
              .fontSize(12)

            this.Section($r('app.string.article_summary'))
            ForEach(this.article.summaryBullets, (bullet: string) => {
              Text(`• ${bullet}`)
                .fontColor($r('app.color.textSecondary'))
                .fontSize(12)
                .width('100%')
            })

            this.Section($r('app.string.article_tags'))
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.article.tags, (tag: string) => {
                Text(`#${tag}`)
                  .fontColor($r('app.color.textPrimary'))
                  .fontSize(11)
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor($r('app.color.surfaceChip'))
                  .borderRadius(10)
                  .margin({ right: 6, bottom: 6 })
              })
            }
            .width('100%')

            Row({ space: 8 }) {
              Button(this.isSaved ? $r('app.string.action_saved') : $r('app.string.action_save'))
                .layoutWeight(1)
                .fontSize(12)
                .fontColor($r('app.color.textPrimary'))
                .backgroundColor(this.isSaved ? $r('app.color.bookmarkAccent') : $r('app.color.surfaceChip'))
                .height(32)
                .borderRadius(16)
                .accessibilityText(this.isSaved ? $r('app.string.action_saved') : $r('app.string.action_save'))
                .onClick(() => {
                  this.toggleSave();
                })
              Button($r('app.string.article_open_topic'))
                .layoutWeight(1)
                .fontSize(12)
                .fontColor($r('app.color.textPrimary'))
                .backgroundColor($r('app.color.backgroundColor'))
                .height(32)
                .borderRadius(16)
                .accessibilityText($r('app.string.article_open_topic'))
                .onClick(() => {
                  if (this.article !== undefined) {
                    const topicParam: CategoryFeedNavParam = {
                      topicId: this.article.topicId,
                      topicTitle: ''
                    };
                    this.pageStack.replacePathByName(Pages.HeadlineFlow, topicParam);
                  }
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 14, bottom: 18 })
        }
        .scrollBar(BarState.Off)
      }
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      const params = ctx.pathInfo.param as ArticleDetailNavParam | undefined;
      this.article = NewsRepository.getArticleDetail(params?.articleId ?? '');
      if (this.article !== undefined) {
        this.isSaved = ReadingStateService.isSaved(this.article.id);
        ReadingStateService.recordRead(this.article.id);
      }
    })
    .onShown(() => {
      if (this.article !== undefined) {
        this.isSaved = ReadingStateService.isSaved(this.article.id);
      }
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  @Builder
  Section(title: ResourceStr) {
    Text(title)
      .fontColor($r('app.color.textPrimary'))
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .margin({ top: 4 })
  }

  private toggleSave(): void {
    if (this.article === undefined) {
      return;
    }
    ReadingStateService.toggleSaved(this.article.id).then((savedNow: boolean) => {
      this.isSaved = savedNow;
      HapticService.pulseSuccess();
    });
  }
}
