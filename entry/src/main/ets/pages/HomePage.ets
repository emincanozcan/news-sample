import { AppNav } from '../models/NavigationModels';
import { ArticleSummary, NewsTopic } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { ReadingStateService } from '../services/ReadingStateService';
import { AppSettingsStore } from '../store/AppSettingsStore';
import { StatePanel } from '../components/StatePanel';
import { ConnectivityService } from '../services/ConnectivityService';
import { StatusBanner } from '../components/StatusBanner';
import { common } from '@kit.AbilityKit';

@Component
export struct HomePage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State topics: NewsTopic[] = NewsRepository.getTopics();
  @State feed: ArticleSummary[] = [];
  @State bookmarkCount: number = 0;
  @State historyCount: number = 0;
  @State isRefreshing: boolean = false;
  @State isOffline: boolean = false;
  @State stale: boolean = false;
  @State lastRefreshLabel: string = '';
  @State refreshRound: number = 0;

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          Text($r('app.string.home_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
          Text($r('app.string.home_updated_now'))
            .fontColor($r('app.color.textSecondary'))
            .fontSize(11)
            .width('100%')
            .textAlign(TextAlign.Center)

          if (this.isOffline) {
            StatusBanner({ text: $r('app.string.status_offline_mode'), tone: 'warning' })
          }
          if (this.stale) {
            StatusBanner({ text: $r('app.string.status_stale_content'), tone: 'warning' })
          }
          Text(this.lastRefreshLabel)
            .fontColor($r('app.color.textSecondary'))
            .fontSize(11)
            .width('100%')
            .textAlign(TextAlign.Center)
          Button(this.isRefreshing ? $r('app.string.status_refreshing') : $r('app.string.action_refresh'))
            .fontSize(12)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.surfaceChip'))
            .width('100%')
            .height(32)
            .borderRadius(16)
            .enabled(!this.isRefreshing)
            .accessibilityText($r('app.string.action_refresh'))
            .onClick(() => {
              this.refreshData(true);
            })

          this.SectionTitle($r('app.string.home_for_you'))
          if (this.feed.length === 0) {
            StatePanel({
              title: $r('app.string.home_for_you'),
              subtitle: $r('app.string.home_empty_feed')
            })
          } else {
            ForEach(this.feed.slice(0, 3), (item: ArticleSummary) => {
              HomeArticleCard({
                article: item,
                onOpen: () => {
                  AppNav.toArticleDetail(this.pageStack, { articleId: item.id, fromTopicId: item.topicId });
                }
              })
            }, (item: ArticleSummary) => item.id)
          }

          this.SectionTitle($r('app.string.home_topics'))
          Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row }) {
            ForEach(this.topics, (item: NewsTopic) => {
              TopicChip({
                title: item.title,
                onTap: () => {
                  AppNav.toHeadlineFlow(this.pageStack, { topicId: item.id, topicTitle: item.title });
                }
              })
            }, (item: NewsTopic) => item.id)
          }
          .width('100%')

          this.SectionTitle($r('app.string.home_library'))
          Row({ space: 8 }) {
            MetricShortcut({
              label: $r('app.string.library_saved_count'),
              value: this.bookmarkCount.toString(),
              a11yLabel: this.getString($r('app.string.a11y_metric_saved')),
              onTap: () => {
                AppNav.toSaved(this.pageStack, { filter: 'all' });
              }
            })
            MetricShortcut({
              label: $r('app.string.library_history_count'),
              value: this.historyCount.toString(),
              a11yLabel: this.getString($r('app.string.a11y_metric_history')),
              onTap: () => {
                AppNav.toHistory(this.pageStack, { filter: 'all' });
              }
            })
          }
          .width('100%')

          this.SectionTitle($r('app.string.home_daily_briefing'))
          Button($r('app.string.nav_briefing'))
            .fontSize(12)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.surfaceChip'))
            .width('100%')
            .height(32)
            .borderRadius(16)
            .accessibilityText($r('app.string.nav_briefing'))
            .onClick(() => {
              AppNav.toBriefing(this.pageStack, { source: 'home' });
            })

          Button($r('app.string.nav_settings'))
            .fontSize(12)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.backgroundColor'))
            .width('100%')
            .height(32)
            .borderRadius(16)
            .accessibilityText($r('app.string.nav_settings'))
            .onClick(() => {
              AppNav.toSettings(this.pageStack);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 20 })
      }
      .scrollBar(BarState.Off)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      this.refreshData(false);
    })
    .onShown(() => {
      this.refreshData(false);
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  @Builder
  SectionTitle(label: ResourceStr) {
    Text(label)
      .fontColor($r('app.color.textPrimary'))
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .textAlign(TextAlign.Start)
  }

  private refreshData(withSpinner: boolean): void {
    if (withSpinner) {
      this.isRefreshing = true;
    }
    const connectivity = ConnectivityService.getState();
    this.isOffline = connectivity.supported && !connectivity.online;
    const now = Date.now();
    const nowDate = new Date(now);
    const lastRefreshAt = (AppStorage.get('news.feed.lastRefreshAt') as number | undefined) ?? now;
    this.stale = now - lastRefreshAt >= 3 * 60 * 60 * 1000;
    AppStorage.setOrCreate('news.feed.lastRefreshAt', now);
    this.lastRefreshLabel = `${this.getString($r('app.string.status_last_updated'))}: ${nowDate.getHours().toString().padStart(2, '0')}:${nowDate.getMinutes().toString().padStart(2, '0')}`;

    const topics = AppSettingsStore.getPreferredTopicIds();
    const personalized = NewsRepository.getPersonalizedFeed(topics);
    if (personalized.length > 0 && this.refreshRound % 2 === 1) {
      this.feed = personalized.slice(1).concat(personalized.slice(0, 1));
    } else {
      this.feed = personalized;
    }
    this.refreshRound += 1;
    this.bookmarkCount = ReadingStateService.getSavedItems().length;
    this.historyCount = ReadingStateService.getReadHistory().length;
    if (withSpinner) {
      setTimeout(() => {
        this.isRefreshing = false;
      }, 350);
    }
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

@Component
struct HomeArticleCard {
  @Prop article: ArticleSummary;
  onOpen?: () => void;

  build() {
    Column({ space: 6 }) {
      Text(this.article.title)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(`${this.article.source} · ${this.article.readMinutes}m`)
        .fontColor($r('app.color.textSecondary'))
        .fontSize(11)
        .maxLines(1)
      if (this.article.isBreaking) {
        Text($r('app.string.label_breaking'))
          .fontColor($r('app.color.bgColor'))
          .fontSize(10)
          .backgroundColor($r('app.color.stateWarning'))
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          .borderRadius(10)
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundColor($r('app.color.surfaceCard'))
    .borderRadius(16)
    .onClick(() => {
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

@Component
struct TopicChip {
  @Prop title: string;
  onTap?: () => void;

  build() {
    Text(this.title)
      .fontColor($r('app.color.textPrimary'))
      .fontSize(12)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor($r('app.color.surfaceChip'))
      .borderRadius(14)
      .margin({ right: 6, bottom: 6 })
      .onClick(() => {
        if (this.onTap) {
          this.onTap();
        }
      })
      .accessibilityText(`${this.getString($r('app.string.a11y_topic_chip'))}: ${this.title}`)
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

@Component
struct MetricShortcut {
  @Prop label: ResourceStr;
  @Prop value: string;
  @Prop a11yLabel: string = '';
  onTap?: () => void;

  build() {
    Column({ space: 4 }) {
      Text(this.value)
        .fontColor($r('app.color.textPrimary'))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
      Text(this.label)
        .fontColor($r('app.color.textSecondary'))
        .fontSize(11)
        .textAlign(TextAlign.Start)
    }
    .layoutWeight(1)
    .padding({ top: 10, bottom: 10 })
    .backgroundColor($r('app.color.surfaceCard'))
    .borderRadius(14)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    })
    .accessibilityText(this.a11yLabel)
  }
}
