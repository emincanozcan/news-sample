import { ArticleSummary } from '../models/NewsModels';
import { common } from '@kit.AbilityKit';

@Component
export struct ArticleListItem {
  @Prop article: ArticleSummary;
  onOpen?: () => void;
  onAction?: () => void;
  @Prop actionLabel: ResourceStr = $r('app.string.action_save');
  @Prop timestampLabel: string = '';
  private lastActionTapTime: number = 0;

  build() {
    Column({ space: 8 }) {
      Text(this.article.title)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Row() {
        Text(`${this.article.source} · ${this.timestampLabel.length > 0 ? this.timestampLabel : this.article.publishedAt} · ${this.article.readMinutes}m`)
          .fontColor($r('app.color.textSecondary'))
          .fontSize(11)
          .layoutWeight(1)
          .maxLines(1)
        Button(this.actionLabel)
          .fontSize(11)
          .fontColor($r('app.color.textPrimary'))
          .backgroundColor($r('app.color.surfaceChip'))
          .height(28)
          .borderRadius(14)
          .accessibilityText($r('app.string.a11y_remove_item'))
          .onClick(() => {
            this.lastActionTapTime = Date.now();
            if (this.onAction) {
              this.onAction();
            }
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.surfaceCard'))
    .borderRadius(16)
    .onClick(() => {
      if (Date.now() - this.lastActionTapTime < 250) {
        return;
      }
      if (this.onOpen) {
        this.onOpen();
      }
    })
    .accessibilityText(`${this.getString($r('app.string.a11y_open_article'))}: ${this.article.title}`)
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
