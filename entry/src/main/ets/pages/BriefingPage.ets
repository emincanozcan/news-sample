import { AppNav } from '../models/NavigationModels';
import { DigestCard } from '../models/NewsModels';
import { NewsRepository } from '../services/NewsRepository';
import { ReadingStateService } from '../services/ReadingStateService';
import { AppSettingsStore } from '../store/AppSettingsStore';
import { StatusBanner } from '../components/StatusBanner';
import { StatePanel } from '../components/StatePanel';
import { ConnectivityService } from '../services/ConnectivityService';
import { HapticService } from '../services/HapticService';
import { common } from '@kit.AbilityKit';

@Component
export struct BriefingPage {
  @Consume('pageStack') pageStack: NavPathStack;
  @State digestCards: DigestCard[] = [];
  @State isLoading: boolean = true;
  @State hasLoadError: boolean = false;
  @State isRefreshing: boolean = false;
  @State isOffline: boolean = false;
  @State stale: boolean = false;
  @State lastRefreshLabel: string = '';

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text($r('app.string.briefing_title'))
            .fontColor($r('app.color.textPrimary'))
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
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
            .enabled(!this.isRefreshing && !this.isLoading)
            .accessibilityText($r('app.string.action_refresh'))
            .onClick(() => {
              this.refreshBriefing(true);
            })

          if (this.isLoading) {
            StatePanel({
              title: $r('app.string.state_loading'),
              subtitle: $r('app.string.briefing_empty_subtitle')
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
              .width('100%')
              .height(30)
              .borderRadius(15)
              .onClick(() => {
                this.refreshBriefing(false);
              })
          } else if (this.digestCards.length === 0) {
            StatePanel({
              title: $r('app.string.briefing_empty_title'),
              subtitle: $r('app.string.briefing_empty_subtitle')
            })
          } else {
            ForEach(this.digestCards, (card: DigestCard) => {
              Column({ space: 4 }) {
                Text(this.toText(card.headline))
                  .fontColor($r('app.color.textPrimary'))
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                Text(this.toText(card.subtitle))
                  .fontColor($r('app.color.textSecondary'))
                  .fontSize(11)
                  .width('100%')
              }
              .width('100%')
              .padding({ left: 10, right: 10, top: 10, bottom: 10 })
              .backgroundColor($r('app.color.surfaceCard'))
              .borderRadius(14)
              .accessibilityText(`${this.toText(card.headline)}. ${this.toText(card.subtitle)}`)
            }, (card: DigestCard) => card.id)
          }

          Button($r('app.string.briefing_mark_done'))
            .fontSize(12)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.bookmarkAccent'))
            .width('100%')
            .height(32)
            .borderRadius(16)
            .accessibilityText($r('app.string.a11y_briefing_done'))
            .onClick(() => {
              HapticService.pulseSuccess();
              this.pageStack.pop();
            })

          Button($r('app.string.nav_settings'))
            .fontSize(12)
            .fontColor($r('app.color.textPrimary'))
            .backgroundColor($r('app.color.backgroundColor'))
            .width('100%')
            .height(32)
            .borderRadius(16)
            .onClick(() => {
              AppNav.toSettings(this.pageStack);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 14, bottom: 20 })
      }
      .scrollBar(BarState.Off)
    }
    .onReady((ctx: NavDestinationContext) => {
      this.pageStack = ctx.pathStack;
      this.refreshBriefing(false);
    })
    .onShown(() => {
      this.refreshBriefing(false);
    })
    .backgroundColor($r('app.color.bgColor'))
    .hideBackButton(true)
  }

  private refreshBriefing(withSpinner: boolean): void {
    this.isLoading = !withSpinner;
    this.hasLoadError = false;
    if (withSpinner) {
      this.isRefreshing = true;
    }
    setTimeout(() => {
      try {
        const connectivity = ConnectivityService.getState();
        this.isOffline = connectivity.supported && !connectivity.online;
        const preferredTopics = AppSettingsStore.getPreferredTopicIds();
        this.digestCards = NewsRepository.getDigestCards(
          preferredTopics,
          ReadingStateService.getSavedItems(),
          ReadingStateService.getReadHistory()
        );
        const now = Date.now();
        const nowDate = new Date(now);
        this.lastRefreshLabel = `${this.getString($r('app.string.status_last_updated'))}: ${nowDate.getHours().toString().padStart(2, '0')}:${nowDate.getMinutes().toString().padStart(2, '0')}`;
        const lastRefreshAt = (AppStorage.get('news.feed.lastRefreshAt') as number | undefined) ?? now;
        this.stale = now - lastRefreshAt >= 3 * 60 * 60 * 1000;
        AppStorage.setOrCreate('news.feed.lastRefreshAt', now);
      } catch (_error) {
        this.hasLoadError = true;
      }
      this.isLoading = false;
      if (withSpinner) {
        this.isRefreshing = false;
      }
    }, withSpinner ? 350 : 120);
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

  private toText(value: ResourceStr | string): string {
    if (typeof value === 'string') {
      return value;
    }
    return this.getString(value);
  }
}
